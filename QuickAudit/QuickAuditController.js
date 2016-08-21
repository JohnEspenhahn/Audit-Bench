"use strict";

angular.module("auditBench")
.controller("QuickAudit", ["$scope", "$http", "abUtils", function ($scope, $http, abUtils) {
    $scope.abUtils = abUtils;

    // Set to true to show errors
    $scope.submitted = false;
    // View toggle variable
    $scope.validating = false;
    // Message strings
    $scope.message = "";
    $scope.error = "";
    // Cached autocomplete
    $scope.manufacturers = [];
    $scope.modelNumbers = [];
    $scope.modelNames = [];
    // Triage data
    $scope.showTriage = true;
    $scope.triageData = null;
    $scope.triageDataOrder = null;

    // Load receipt from query
    var receiptID = abUtils.getQueryVariable("receiptID");
    if (!receiptID) return;

    // On class change load possible manufacturers
    $scope.classChange = function () {
        $scope.triageData = null;
        $scope.triageDataOrder = null;
        $scope.manufacturers = [];
        $scope.modelNumbers = [];
        $scope.modelNames = [];

        if (!$scope.audit.classID) {
            return;
        }

        // Load typeahead manufacturers
        $http.get("/api/auditmodel/find/manufacturer/" + $scope.audit.classID)
            .then(function (res) { $scope.manufacturers = res.data; });

        // Load the class to see if should show value triage
        $http.get("/api/classes/" + $scope.audit.classID)
            .then(function (res) { $scope.showTriage = res.data.ValueTriage; });

        // Load triage display order information
        $http.get("/api/auditmodel/triage/order/" + $scope.audit.classID)
            .then(function (res) { $scope.triageDataOrder = res.data; });
    };

    // Once we are down to only one possible manufacturer, load the model names and numbers
    $scope.manufacturerChange = function (manufs) {
        if (manufs.length != 1) {
            $scope.triageData = null;
            $scope.modelNumbers = [];
            $scope.modelNames = [];
            return;
        }

        var manuf = manufs[0];
        $http.get("/api/auditmodel/find/modelnumber/" + manuf.ManufID)
            .then(function (res) { $scope.modelNumbers = res.data; });

        $http.get("/api/auditmodel/find/modelname/" + manuf.ManufID)
            .then(function (res) { $scope.modelNames = res.data; });
    };

    // Get a legal manufacturer locally
    $scope.getManufacturer = function (manuf) {
        if (!manuf) return null;
        else return abUtils.find($scope.manufacturers, manuf, "Manufacturer");
    };

    // Add a new manufacturer
    $scope.newManufacturer = function () {
        if (!$scope.audit.classID) return;

        var newVal = prompt("New manufacturer:", $scope.auditForm.manufacturer.$viewValue);
        if (!newVal) return;

        LoadingOverlay(true);
        $http.post(
            "/api/auditmodel/manufacturer", {
                ClassID: $scope.audit.classID,
                Manufacturer: newVal
            }).then(function (res) {
                LoadingOverlay(false);

                var manuf = res.data;
                $scope.manufacturers.push(manuf);
                $scope.audit.manufacturer = manuf.Manufacturer;
            }, _PostFail);
    };

    // When model number changes see if we can determine the model name
    $scope.modeNumberChange = function (modelNums) {
        $scope.triageData = null;
        if (modelNums.length != 1) return;
        var modelNum = modelNums[0];

        // Check that found a unique model number that is linked to a model name
        if (modelNum.ModelNameID) {
            $http.get("/api/auditmodel/modelname" + modelNum.ModelNameID)
                .then(function (res) {
                    var data = res.data;
                    if (data && data.ModelName) {
                        $scope.modelNames = [data];
                        $scope.audit.modelName = data.ModelName;
                    }
                });
        }

        // Run triage
        var manuf = $scope.getManufacturer($scope.audit.manufacturer);
        if (manuf) {
            $http.post("/api/auditmodel/triage", {
                    Manufacturer: manuf.Manufacturer,
                    ModelNumber: modelNum.ModelNum
                }).then(function (res) {
                    $scope.triageData = res.data;
                });
        }
    };

    // Get a legal model number locally
    $scope.getModelNumber = function (modelNum) {
        if (!modelNum) return null;
        else return abUtils.find($scope.modelNumbers, modelNum, "ModelNum");
    };

    // Add a new model number
    $scope.newModelNumber = function () {
        var manuf = $scope.getManufacturer($scope.audit.manufacturer);
        if (!manuf) return;

        var newVal = prompt("New Model Number:", $scope.auditForm.modelNumber.$viewValue);
        if (!newVal) return;

        LoadingOverlay(true);
        $http.post(
            "/api/auditmodel/modelnumber", {
                ManufID: manuf.ManufID,
                ModelNum: newVal
            }).then(function (res) {
                LoadingOverlay(false);

                var modelnum = res.data;
                $scope.modelNumbers.push(modelnum);
                $scope.audit.modelNumber = modelnum.ModelNum;
            }, _PostFail);
    };

    // Get a legal model name locally
    $scope.getModelName = function (modelName) {
        if (!modelName) return null;
        else return abUtils.find($scope.modelNames, modelName, "ModelName");
    };

    // Add a new model name
    $scope.newModelName = function () {
        var manuf = $scope.getManufacturer($scope.audit.manufacturer);
        if (!manuf) return;

        var newVal = prompt("New Model Name:", $scope.auditForm.modelName.$viewValue);
        if (!newVal) return;

        LoadingOverlay(true);
        $http.post(
            "/api/auditmodel/modelname", {
                ManufID: manuf.ManufID,
                ModelName: newVal
            }).then(function (res) {
                LoadingOverlay(false);

                var modelname = res.data;
                $scope.modelNames.push(modelname);
                $scope.audit.modelName = modelname.ModelName;
            }, _PostFail);
    };

    // Called when a post to add an item fails
    function _PostFail(err) {
        console.log(err);
        LoadingOverlay(false);
        alert("Failed add item!");
    }
    
    // Validate the audit
    $scope.validateAudit = function () {
        $scope.error = $scope.message = "";
        if ($scope.auditForm.$invalid) {
            $scope.submitted = true;

			// Scroll to first invalid
            var target = $(".form-control.ng-invalid:first").focus();
            $(document).scrollTop(Math.max(0, target.offset().top - 120));
        } else {
            $scope.validating = true;
            $(document).scrollTop(0);
        }
    };

    // Go back to input display
    $scope.editAudit = function () {
        $scope.validating = false;
        $scope.submitted = false;
    };

    // Save the audit then reset the input
    $scope.saveAudit = function () {
        $scope.saveAndDupAudit().then(function () {
            if (!$scope.error) $scope.initAudit();
        });
    };

    // Save the audit without reseting the input
    $scope.saveAndDupAudit = function () {
        LoadingOverlay(true);
        return $http.post("/api/audit/", $scope.audit)
            .then(function () {
                _saveFinished();
                $scope.message = "Save successful";
            }, function (err) {
                _saveFinished();

                if (err.data && err.data.Message)
                    $scope.error = err.data.Message;
                else {
                    console.log(err);
                    alert("Failed to save changes!");
                }
            });
    };

    // Called by saveAndDupAudit when got response (success OR fail)
    function _saveFinished() {
        LoadingOverlay(false);
        $scope.audit.assetID = "";
        $scope.editAudit();
        $(document).scrollTop(0);
        $("#MainContent_AssetID").focus();
    }

    // Init/reset the audit
    $scope.initAudit = function () {
        $scope.audit = {
            assetID: null,
            classID: null,
            qty: 1,
            manufacturer: null,
            modelName: null,
            modelNumber: null,
            serialNumber: null,
            weight: null,
            location: null,
            receiptID: receiptID
        };
    };

    $scope.initAudit();
}])
    
// A filter to find elements in the array where the object in key `key` starts with `val`
.filter("startsWith", function () {
    return function (arr, val, key) {
        val = val.toUpperCase();

        var vallng = val.length
          , result = [];

        for (var i = 0, ii = arr.length; i < ii; i++) {
            var e = arr[i];
            if (e[key].substr(0, vallng).toUpperCase() === val) {
                result.push(e);
            }
        }

        return result;
    };
});