<%@ Page Language="C#" Title="Quick Audit" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="QuickAudit.aspx.cs" Inherits="AuditBench.QuickAudit" %>

<asp:Content ID="MyHeaderContent" ContentPlaceHolderID="HeaderContent" runat="Server">	
	<!-- AngularJS controller for this page -->
    <script src="QuickAuditController.js"></script>
</asp:Content>

<asp:Content ID="MyContent" ContentPlaceHolderID="MainContent" runat="Server">
    <div ng-controller="QuickAudit">
        <div class="row">
            <div class="col-lg-6">
                <!-- Messages from angular -->
                <div class="alert alert-danger ng-hide" role="alert" ng-bind="error" ng-show="error"></div>
                <div class="alert alert-info ng-hide" role="alert" ng-bind="message" ng-show="message"></div>
                
				<!-- Notifications from CodeBehind -->
                <span id="NotificationDiv" runat="server"></span>
            </div>
        </div>
        
        <div id="InputDiv" class="form-horizontal col-lg-7" ng-hide="validating">
            <div class="panel panel-default" name="auditForm" ng-form>
                <div class="panel-heading">Quick Audit</div>
                <div class="panel-body" ng-cloak>
                    <div class="form-group form-group-close">
                        <label class="col-lg-4 control-label">Receipt #</label>
                        <label class="col-lg-6">
                            <h5 ID="ReceiptNumber" runat="server"></h5>
                        </label>
                    </div>
                    <div class="form-group form-group-close">
                        <label class="col-lg-4 control-label">Job #</label>
                        <label class="col-lg-6">
                            <h5 ID="JobNumber" runat="server"></h5>
                        </label>
                    </div>
                    <div class="form-group form-group-close">
                        <label class="col-lg-4 control-label">Plant Name</label>
                        <label class="col-lg-6">
                            <h5 ID="PlantName" runat="server"></h5>
                        </label>
                    </div>
                    <div class="form-group form-group-close">
                        <asp:Label runat="server" AssociatedControlID="ClassID" CssClass="col-lg-4 control-label">
                            Class *
                        </asp:Label>
                        <div class="col-lg-6">
                            <asp:DropDownList ID="ClassID" ng-model="audit.classID" form-alias="auditForm.classID" ng-change="classChange()" runat="server" 
                                    CssClass="form-control" DataSourceID="dsClasses" DataTextField="className" DataValueField="classID" AppendDataBoundItems="true" required>
                                <asp:ListItem Text="---" Value=""></asp:ListItem>
                            </asp:DropDownList>
                            <span class="text-danger" ng-messages="submitted && auditForm.classID.$error">
                                <span ng-message="required">Class field is required.</span>&nbsp;
                            </span>

                            <%-- Get Classes --%>
                            <asp:LinqDataSource ID="dsClasses" runat="server" OnSelecting="dsClasses_Selecting" />
                        </div>
                    </div>
                    <div class="form-group form-group-close">
                        <label for="Qty" class="col-lg-4 control-label">
                            Quantity *
                        </label>
                        <div class="col-lg-6">
                            <input type="number" name="qty" ID="Qty" ng-model="audit.qty" class="form-control" value="1" ng-pattern="/^[0-9]{1,7}$/" required />
                            <span class="text-danger" ng-messages="submitted && auditForm.qty.$error">
                                <span ng-message="required">The quantity field is required.</span>
                                <span ng-message="pattern">Not a valid quantity.</span>
                                <span ng-message="number">Not a valid quantity.</span>
                                &nbsp;
                            </span>
                        </div>
                    </div>
                    <div class="form-group form-group-close">
                        <label for="AssetID" class="col-lg-4 control-label">
                            Asset ID *
                        </label>
                        <div class="col-lg-6">
                            <input type="text" name="assetID" ID="AssetID" ng-model="audit.assetID" class="form-control" required />
                            <span class="text-danger" ng-messages="submitted && auditForm.assetID.$error">
                                <span ng-message="required">The asset id field is required.</span>&nbsp;
                            </span>
                        </div>
                    </div>
                    <div class="form-group form-group-close">
                        <label class="col-lg-4 control-label">
                            Manufacturer *
                        </label>
                        <div class="col-lg-6">
                            <input type="text" name="manufacturer" id="Manufacturer" class="form-control" autocomplete="off" typeahead-show-hint="true"
                                ng-model="audit.manufacturer" typeahead-select-on-exact="true" typeahead-wait-ms="100"
                                typeahead-on-select="manufacturerChange([ $item ])"
                                ng-change="manufacturerChange(manufacturers | filter:{'Manufacturer':audit.manufacturer}:true)" 
                                uib-typeahead="m.Manufacturer for m in manufacturers | startsWith:$viewValue:'Manufacturer'" 
                                ui-validate="'!!getManufacturer($value)'" ui-validate-watch-collection="'manufacturers'" required />

                            <span class="text-danger" ng-messages="submitted && auditForm.manufacturer.$error">
                                <span ng-message="required">The manufacturer field is required.</span>
                                <span ng-message="validator">Illegal manufacturer.</span>&nbsp;
                            </span>
                        </div>
                        <div class="col-lg-2" runat="server" id="EditManufacturerDiv" visible="false" style="padding:4px 2px;">
                            <a href="#" class="ng-hide" ng-show="audit.classID" ng-click="newManufacturer()" tabIndex="-1">
                                <i class="fa fa-fw fa-pencil" aria-hidden="true"></i>
                            </a>
                        </div>
                    </div>
                    <div class="form-group form-group-close">
                        <label class="col-lg-4 control-label">
                            Model Number *
                        </label>
                        <div class="col-lg-6">
                            <input type="text" name="modelNumber" id="ModelNumber" class="form-control" autocomplete="off" typeahead-show-hint="true" 
                                ng-model="audit.modelNumber" typeahead-select-on-exact="true" typeahead-wait-ms="100"
                                typeahead-on-select="modeNumberChange([ $item ])"
                                ng-change="modeNumberChange(modelNumbers | filter:{'ModelNum': audit.modelNumber}:true)" 
                                uib-typeahead="m.ModelNum for m in modelNumbers | startsWith:$viewValue:'ModelNum'" 
                                ui-validate="'!!getModelNumber($value)'" ui-validate-watch-collection="'modelNumbers'" required />

                            <span class="text-danger" ng-messages="submitted && auditForm.modelNumber.$error">
                                <span ng-message="required">The model number field is required.</span>
                                <span ng-message="validator">Illegal model number.</span>&nbsp;
                            </span>
                        </div>
                        <div class="col-lg-2" runat="server" id="EditModelNumberDiv" visible="false" style="padding:4px 2px;">
                            <a href="#" class="ng-hide" ng-show="!!getManufacturer(audit.manufacturer)" ng-click="newModelNumber()" tabIndex="-1">
                                <i class="fa fa-fw fa-pencil" aria-hidden="true"></i>
                            </a>
                        </div>
                    </div>
                    <div class="form-group form-group-close">
                        <label class="col-lg-4 control-label">
                            Model Name *
                        </label>
                        <div class="col-lg-6">
                            <input type="text" name="modelName" id="ModelName" class="form-control" autocomplete="off" typeahead-show-hint="true"
                                ng-model="audit.modelName" typeahead-select-on-exact="true" typeahead-wait-ms="100"
                                uib-typeahead="m.ModelName for m in modelNames | startsWith:$viewValue:'ModelName'" 
                                ui-validate="'!!getModelName($value)'" ui-validate-watch-collection="'modelNames'" required />

                            <span class="text-danger" ng-messages="submitted && auditForm.modelName.$error">
                                <span ng-message="required">The model name field is required.</span>
                                <span ng-message="validator">Illegal model name.</span>&nbsp;
                            </span>
                        </div>
                        <div class="col-lg-2" runat="server" id="EditModelNameDiv" visible="false" style="padding:4px 2px;">
                            <a href="#" class="ng-hide" ng-show="!!getManufacturer(audit.manufacturer)" ng-click="newModelName()" tabIndex="-1">
                                <i class="fa fa-fw fa-pencil" aria-hidden="true"></i>
                            </a>
                        </div>
                    </div>
                    <div class="form-group form-group-close">
                        <label for="SerialNumber" class="col-lg-4 control-label">
                            Serial Number *
                        </label>
                        <div class="col-lg-6">
                            <input type="text" ID="SerialNumber" name="serialNumber" ng-model="audit.serialNumber" class="form-control" required />
                            <span class="text-danger" ng-messages="submitted && auditForm.serialNumber.$error">
                                <span ng-message="required">The serial number field is required.</span>&nbsp;
                            </span>
                        </div>
                    </div>
                    <div class="form-group form-group-close">
                        <label for="Weight" class="col-lg-4 control-label">
                            Weight *
                        </label>
                        <div class="col-lg-6">
                            <input type="number" name="weight" ID="Weight" ng-model="audit.weight" class="form-control" ng-pattern="/^[0-9]*\.?[0-9]+$/" required />
                            <span class="text-danger" ng-messages="submitted && auditForm.weight.$error">
                                <span ng-message="required">The weight field is required.</span>
                                <span ng-message="pattern">Not a valid weight.</span>
                                &nbsp;
                            </span>
                        </div>
                    </div>
                    <div class="form-group form-group-close">
                        <label for="Location" class="col-lg-4 control-label">
                            Location *
                        </label>
                        <div class="col-lg-6">
                            <input type="text" name="location" ID="Location" ng-model="audit.location" class="form-control" required />
                            <span class="text-danger" ng-messages="submitted && auditForm.location.$error">
                                <span ng-message="required">The location field is required.</span>&nbsp;
                            </span>
                        </div>
                    </div>
                </div> <%-- / .panel-body --%>
            </div> <%-- / .panel --%>

            <div class="form-group">
                <div class="col-lg-6">
                    <button type="button" ng-click="validateAudit()" class="btn btn-default">Submit</button>&nbsp;&nbsp;
                    <a href="/" onclick="return confirm('Do you really want to leave this page?');" class="btn btn-default" role="button">Cancel</a>
                </div>
            </div>
        </div>  
        <%-- / #InputDiv --%>

        <div id="ValidateDiv" class="form-horizontal col-lg-7 ng-hide" ng-show="validating">
            <div class="panel panel-default">
                <div class="panel-heading">Quick Audit - Validate</div>
                <div class="panel-body">
                    <div class="form-group">
                        <label class="col-lg-4 control-label">Receipt #</label>
                        <label class="col-lg-6">
                            <h5 ID="ReceiptNumber2" runat="server"></h5>
                        </label>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-4 control-label">Job #</label>
                        <label class="col-lg-6">
                            <h5 ID="JobNumber2" runat="server"></h5>
                        </label>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-4 control-label">Plant Name</label>
                        <label class="col-lg-6">
                            <h5 ID="PlantName2" runat="server"></h5>
                        </label>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-4 control-label">
                            Class
                        </label>
                        <div class="col-lg-6">
                            <h5 ng-bind="audit.classID"></h5>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-4 control-label">
                            Quantity
                        </label>
                        <div class="col-lg-6">
                            <h5 ng-bind="audit.qty"></h5>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-4 control-label">
                            Asset ID
                        </label>
                        <div class="col-lg-6">
                            <h5 ng-bind="audit.assetID"></h5>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-4 control-label">
                            Manufacturer
                        </label>
                        <div class="col-lg-6">
                            <h5 ng-bind="audit.manufacturer"></h5>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-4 control-label">
                            Model Number
                        </label>
                        <div class="col-lg-6">
                            <h5 ng-bind="audit.modelNumber"></h5>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-4 control-label">
                            Model Name
                        </label>
                        <div class="col-lg-6">
                            <h5 ng-bind="audit.modelName"></h5>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-4 control-label">
                            Serial Number
                        </label>
                        <div class="col-lg-6">
                            <h5 ng-bind="audit.serialNumber"></h5>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-4 control-label">
                            Weight
                        </label>
                        <div class="col-lg-6">
                            <h5 ng-bind="audit.weight"></h5>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-4 control-label">
                            Location
                        </label>
                        <div class="col-lg-6">
                            <h5 ng-bind="audit.location"></h5>
                        </div>
                    </div>
                </div> <%-- / .panel-body --%>
            </div> <%-- / .panel --%>

            <div class="form-group">
                <div class="col-lg-9">
                    <button type="button" ng-click="editAudit()" class="btn btn-default">Edit</button>&nbsp;&nbsp;
                    <button type="button" ng-click="saveAudit()" class="btn btn-default">Save</button>&nbsp;&nbsp;
                    <button type="button" ng-click="saveAndDupAudit()" class="btn btn-default">Save & Duplicate</button>
                </div>
            </div>
        </div>
        <%-- / #ValidateDiv --%>

        <div id="Triage" class="col-lg-5">
            <div class="panel panel-default ng-hide" style="overflow-x:scroll;" ng-show="showTriage && triageData && triageDataOrder">
                <div class="panel-heading">Recent Assets With Same Model</div>
                <table class="table table-striped table-bordered">
                    <thead>
                        <tr>
                            <th ng-repeat="(_, order) in triageDataOrder">
                                {{order.Title}}
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr ng-repeat="triage in triageData">
                            <td ng-repeat="(_, order) in triageDataOrder">
                                {{triage[order.Name]}} <%-- Get the column with the name based on order data --%>
                            </td>
                        </tr>
                        <tr ng-show="!!triageData && triageData.length === 0">
                            <td colspan="{{triageDataOrder.length}}">No records found</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div> <!-- / #Triage -->
    </div> <%-- / ng-controller="QuickAudit" --%>

</asp:Content>
