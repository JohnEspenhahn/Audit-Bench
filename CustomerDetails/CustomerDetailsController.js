"use strict";

angular.module('auditBench')

.controller("CustomerDetails", ["$scope", "$http", "abUtils", function ($scope, $http, abUtils) {
    $scope.abUtils = abUtils;

    $scope.salesperson = null;

    $scope.customer = null;
    $scope.customer2 = null;

    // Toggle off edit notes
    $scope.editingNotes = false;
    window.document.onclick = function (event) {
        if (event.target.id !== 'Notes' && event.target.id !== 'EditNotes') {
            $scope.editingNotes = false;
            window.document.body.focus();
        }
    };

    // Load vendor ID from query string
    $scope.vendorID = abUtils.getQueryVariable("VendorID");
    if (!$scope.vendorID) return;

    // PUT edits to the customer to the server (server will only allow edits from Admin)
    $scope.saveCustomerEdits = function () {
        abUtils.shallowClone($scope.customer2, $scope.customer);
        $http.put('/api/customers/' + $scope.vendorID, $scope.customer)
            .then(function (res) {
                // Response has updated DateModified
                $scope.customer = res.data;
                $scope.customer2 = abUtils.shallowClone(res.data, {}); // A copy
            }, function (err) {
                console.log(err);
                alert("Failed to save changes!");
            });
    };

    // Only post save if notes changed
    $scope.saveNotesEdit = function () {
        if ($scope.customer2.notes !== $scope.customer.notes)
            $scope.saveCustomerEdits();
    };

    // Load general customer
    $http.get('/api/customers/' + $scope.vendorID)
        .then(function (res) {
            $scope.customer = res.data;
            $scope.customer2 = abUtils.shallowClone(res.data, {}); // A copy
        }, function (err) {
            console.log(err);
            alert('Failed to load customer!');
        }
    );

    // Load sales person (TODO make editable here)
    $http.get('/api/customers/salesperson/' + $scope.vendorID)
        .then(function (res) {
            if (!res || !res.data) return;

            $scope.salesperson = res.data;
        }, function (err) {
            console.log(err);
            alert("Failed to load sales person!");
        }
    );
}]);