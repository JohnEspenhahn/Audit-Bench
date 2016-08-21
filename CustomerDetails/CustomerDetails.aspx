<%@ Page Language="C#" Title="Customer Details" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CustomerDetails.aspx.cs" Inherits="AuditBench.CustomerDetails" %>

<asp:Content ID="MyHeaderContent" ContentPlaceHolderID="HeaderContent" runat="Server">	
	<!-- AngularJS controller for this page -->
    <script src="/Scripts/Angular/CustomerDetailsController.js"></script>
</asp:Content>

<asp:Content ID="MyContent" ContentPlaceHolderID="MainContent" runat="Server">
    <div ng-controller="CustomerDetails">

        <!-- Heading Area -->
        <div id="content-heading">
            <div class="panel panel-default">
                <div class="panel-body" style="min-height:20em;">
					<!-- Open edit modal -->
                    <button id="TopEditButton" visible="false" type="button" class="btn btn-default pull-right" 
							data-toggle="modal" data-target="#cdModal" runat="server">
                        Edit
                    </button>

                    <div class="col-lg-6">
                        <h3 ng-bind="customer.vendorName"></h3>
                        <h4 ng-bind="customer.Contact">Loading...</h4>
                        <div ng-cloak>
                            <div>
                                <span ng-bind="customer.Phone"></span>
                                &nbsp;&nbsp;&nbsp;
                                <span ng-bind="customer.email1"></span>
                            </div>
                            <span ng-show="salesperson.firstname">Sales Person: {{salesperson.firstName}} {{salesperson.lastName}}</span>
                            <br />
                            <br />
                        
                            <textarea id="Notes" rows="3" cols="50" ng-model="customer2.notes" ng-trim="true" focus-on="editingNotes" ng-blur="saveNotesEdit()" ng-readonly="!editingNotes"></textarea>
                        
                            <div id="EditNotesGroup" visible="true" runat="server" ng-hide="editingNotes">
                                <br />
                                <a href="#" id="EditNotes" class="blue" ng-click="editingNotes=true">
                                    Edit Notes
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Notifications -->
        <span id="NotificationDiv" runat="server"></span>

        <div>
            <!-- Tab Nav -->
            <ul id="tabs-nav" class="nav nav-tabs" role="tablist">
                <li role="presentation" class="active">
                    <a href="#jobs" aria-controls="jobs" role="tab" data-toggle="tab">Jobs</a>
                </li>
                <li role="presentation">
                    <a href="#details" aria-controls="details" role="tab" data-toggle="tab">Details</a>
                </li>
                <li role="presentation">
                    <a href="#opportunities" aria-controls="opportunities" role="tab" data-toggle="tab">Opportunities</a>
                </li>
            </ul>

            <!-- Tab panes -->
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane active" id="jobs">
                    <asp:Panel ID="p" runat="server" DefaultButton="HiddenASPButton">
                        <!-- Autocomplete controller -->
                        <div class="row">
                            <div class="col-lg-4">
                                <div class="input-group attach-bottom">
                                    <input type="text" id="TypeaheadField" name="TypeaheadField"  class="form-control" autocomplete="off" typeahead-show-hint="true"
                                        ng-model="typeahead" typeahead-select-on-exact="true" typeahead-loading="loadingLocations"
                                        placeholder="Search by job number" uib-typeahead="job.JobNumber for job in abUtils.GET('/api/jobs/find/10/' + vendorID, $viewValue)" />

                                    <span class="input-group-btn">
                                        <button ID="SearchButton" class="btn btn-default" type="submit" runat="server" onserverclick="SearchButton_Click">
                                            <i ng-hide="loadingLocations" class="glyphicon glyphicon-search"></i>
                                            <i ng-show="loadingLocations" class="glyphicon glyphicon-refresh ng-hide"></i>
                                        </button>
                                    </span>
                                </div><!-- /input-group -->
                            </div>
                            <div class="col-lg-3">
                                <button type="button" class="btn btn-default" runat="server" ID="SearchBackButton" visible="false" onserverclick="SearchBackButton_ServerClick">
                                    Clear Search
                                </button>
                            </div>
                            <%-- ASP Fields --%>
                            <input type="text" ID="SearchField" runat="server" ng-model="typeahead" style="display:none;" />
                            <asp:Button ID="HiddenASPButton"  OnClick="SearchButton_Click" runat="server" style="display:none;" />
                        </div> <!-- / .row -->
                    </asp:Panel>
					<!-- Table to display all jobs -->
                    <asp:GridView ID="JobsView" runat="server" DataSourceID="dsJobs" CssClass="table table-striped table-bordered" 
                            ShowHeaderWhenEmpty="True" EmptyDataText="No records Found" AutoGenerateColumns="False" 
                            DataKeyNames="leaseID" AllowSorting="False" AllowPaging="true" PageSize="30" AllowCustomPaging="false" ShowFooter="False" >

                        <Columns>
                            <asp:BoundField DataField="leaseID" HeaderText="leaseID" InsertVisible="False" ReadOnly="True" ShowHeader="False" SortExpression="leaseID" Visible="False" />
                            <asp:BoundField DataField="Received" HeaderText="Received" SortExpression="Received" DataFormatString="{0:d}" />
                            <asp:BoundField DataField="Customer" HeaderText="Customer" SortExpression="Customer" />
                            <asp:BoundField DataField="Location" HeaderText="Location" SortExpression="Location" />
                            <asp:HyperLinkField DataTextField="JobNumber" DataTextFormatString="{0}" DataNavigateUrlFields="leaseID" DataNavigateUrlFormatString="/Reports/AuditReportTabbed?leaseID={0}" HeaderText="Job #" SortExpression="JobNumber" ControlStyle-CssClass="blue" />
                            <asp:BoundField DataField="ReceiptNumber" HeaderText="Receipt #" SortExpression="ReceiptNumber" />
                            <asp:BoundField DataField="DaysInHouse" ItemStyle-HorizontalAlign="Center" HeaderText="Days In House" SortExpression="DaysInHouse" />
                            <asp:BoundField DataField="Status" HeaderText="Status" SortExpression="Status" />
                        </Columns>
                    </asp:GridView>

                    <%-- Jobs Data Source --%>
                    <asp:LinqDataSource ID="dsJobs" runat="server" OnSelecting="dsJobs_Selecting">
                        <SelectParameters>
                            <asp:QueryStringParameter Name="VendorID" QueryStringField="VendorID" Type="Int32" />
                            <asp:Parameter Name="JobNumber" Type="String" DefaultValue="" ConvertEmptyStringToNull="true" />
                        </SelectParameters>
                    </asp:LinqDataSource>
                </div> <!-- / .tabpanel -->

				<!-- Tab to view details of this customer -->
                <div role="tabpanel" class="tab-pane" id="details">
                    <button id="InTabEditButton" visible="false" type="button" class="btn btn-default pull-right" data-toggle="modal" data-target="#cdModal" runat="server">
                        Edit
                    </button>

                    <div class="form-horizontal">
                        <div class="form-group">
                            <div class="col-lg-6">
                                <label class="control-label">Customer Name</label>
                                <div ng-bind="customer.vendorName"></div>
                            </div>
                            <div class="col-lg-6">
                                <label class="control-label">Sales Person</label>
                                <div ng-bind="salesperson.fullName"></div>
                            </div>
                        </div>
                        <hr />
                        <h4>Primary Contact</h4>
                        <div class="form-group">
                            <div class="col-lg-6">
                                <label class="control-label">Contact</label>
                                <div ng-bind="customer.Contact"></div>
                            </div>
                            <div class="col-lg-6">
                                <label class="control-label">Phone Number</label>
                                <div ng-bind="customer.Phone"></div>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-lg-6">
                                <label class="control-label">Mobile</label>
                                <div ng-bind="customer.mobile"></div>
                            </div>
                            <div class="col-lg-6">
                                <label class="control-label">Email</label>
                                <div ng-bind="customer.email1" ></div>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-lg-6">
                                <label class="control-label">Fax</label>
                                <div ng-bind="customer.fax"></div>
                            </div>
                        </div>
                        <hr />
                        <h4>Alternate Contact</h4>
                        <div class="form-group">
                            <div class="col-lg-6">
                                <label class="control-label">Contact Name</label>
                                <div ng-bind="customer.altcontact"></div>
                            </div>
                            <div class="col-lg-6">
                                <label class="control-label">Phone Number</label>
                                <div ng-bind="customer.altphone"></div>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-lg-6">
                                <label class="control-label">Mobile</label>
                                <div ng-bind="customer.altmobile"></div>
                            </div>
                            <div class="col-lg-6">
                                <label class="control-label">Email</label>
                                <div ng-bind="customer.altemail"></div>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-lg-6">
                                <label class="control-label">Fax</label>
                                <div ng-bind="customer.altfax"></div>
                            </div>
                            <div class="col-lg-6" ng-show="customer.DateModified">
                                <label class="control-label">Date Modified</label>
                                <div ng-bind="abUtils.dateToString(customer.DateModified)"></div>
                            </div>
                        </div>
                        <hr />
                        <div class="form-group">
                            <div class="col-lg-8">
                                <label class="control-label">Address</label>
                                <div ng-cloak>
                                    {{ customer.Address1 }} 
                                    <span ng-show="customer.Address1"><br /></span>
                                    {{ customer.Address2 }} 
                                    <span ng-show="customer.Address2"><br /></span>
                                    {{ customer.City }} 
                                    <span ng-show="customer.City && customer.State">,&nbsp;</span> 
                                    {{ customer.State }}
                                    <span ng-show="(customer.City || customer.State) && customer.Zip">,&nbsp;</span> 
                                    {{ customer.Zip }}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Opportunities -->
                <div role="tabpanel" class="tab-pane" id="opportunities">
                    <button id="NewOpportunities" type="button" class="btn btn-default" disabled="disabled" runat="server">
                        New Opportunities</button>
                </div>
            </div>
        </div>

        <a href="Customers" class="btn btn-default">Done</a>

        <!-- Edit Customer Details Modal -->
        <div id="cdModal" class="modal fade" role="dialog" data-keyboard="false" data-backdrop="static">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <!-- Top right close button, reset -->
                        <button type="button" class="close" data-dismiss="modal"
                            ng-click="abUtils.shallowClone(customer, customer2);">&times;</button>

                        <h4 class="modal-title">Customer Information</h4>
                    </div>
                    <div class="modal-body">
                        <div class="form-horizontal">
                            <div class="form-group">
                                <div class="col-lg-6">
                                    <label for="EditCustomerName" class="control-label">Customer Name</label>
                                    <input type="text" ng-model="customer2.vendorName" ID="EditCustomerName" class="form-control" />
                                </div>
                                <!-- TODO -->
                                <!--
                                <div class="col-lg-6">
                                    <label for="EditSalesPerson" class="control-label">Sales Person</label>
                                    
                                    <input type="text" id="EditSalesPerson" MaxLength="50" class="form-control" />
                                </div>
                                -->
                            </div>
                            <hr />
                            <h4>Primary Contact</h4>
                            <div class="form-group">
                                <div class="col-lg-6">
                                    <label for="EditContactName" class="control-label">Contact Name</label>
                                    <input type="text" ng-model="customer2.Contact" ID="EditContactName" class="form-control" />
                                </div>
                                <div class="col-lg-6">
                                    <label for="EditPhoneNumber" class="control-label">Phone Number</label>
                                    <input type="text" ng-model="customer2.Phone" ID="EditPhoneNumber" class="form-control" />
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-lg-6">
                                    <label for="EditMobile" class="control-label">Mobile</label>
                                    <input type="text" ng-model="customer2.mobile" ID="EditMobile" class="form-control" />
                                </div>
                                <div class="col-lg-6">
                                    <label for="EditEmail" class="control-label">Email</label>
                                    <input type="text" ng-model="customer2.email1" ID="EditEmail" class="form-control" />
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-lg-6">
                                    <label for="EditFax" class="control-label">Fax</label>
                                    <input type="text" ng-model="customer2.fax" ID="EditFax" class="form-control" />
                                </div>
                            </div>
                            <hr />
                            <h4>Alternate Contact</h4>
                            <div class="form-group">
                                <div class="col-lg-6">
                                    <label for="EditContactName2" class="control-label">Contact Name</label>
                                    <input type="text" ng-model="customer2.altcontact" ID="EditContactName2" class="form-control" />
                                </div>
                                <div class="col-lg-6">
                                    <label for="EditPhoneNumber2" class="control-label">Phone Number</label>
                                    <input type="text" ng-model="customer2.altphone" ID="EditPhoneNumber2" class="form-control" />
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-lg-6">
                                    <label for="EditMobile2" class="control-label">Mobile</label>
                                    <input type="text" ng-model="customer2.altmobile" ID="EditMobile2" class="form-control" />
                                </div>
                                <div class="col-lg-6">
                                    <label for="EditEmail2" class="control-label">Email</label>
                                    <input type="text" ng-model="customer2.altemail" ID="EditEmail2" class="form-control" />
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-lg-6">
                                    <label for="EditFax2" class="control-label">Fax</label>
                                    <input type="text" ng-model="customer2.altfax" ID="EditFax2" class="form-control" />
                                </div>
                            </div>
                            <hr />
                            <asp:Label runat="server" for="EditAddress1" class="control-label">Address</asp:Label>
                            <div class="form-group">
                                <div class="col-lg-6">
                                    <input type="text" ng-model="customer2.Address1" ID="EditAddress1" class="form-control" placeholder="Address Line 1" />
                                </div>
                                <div class="col-lg-3">
                                    <input type="text" ng-model="customer2.City" ID="EditCity" class="form-control" placeholder="City" />
                                </div>
                                <div class="col-lg-3">
                                    <select runat="server" ng-model="customer2.State" ID="EditState" class="form-control">
                                        <option value="">---</option>
                                        <option value="AK">AK</option>
                                        <option value="AL">AL</option>
                                        <option value="AR">AR</option>
	                                    <option value="AZ">AZ</option>
	                                    <option value="CA">CA</option>
	                                    <option value="CO">CO</option>
	                                    <option value="CT">CT</option>
                                        <option value="DC">DC</option>
	                                    <option value="DE">DE</option>
	                                    <option value="FL">FL</option>
	                                    <option value="GA">GA</option>
	                                    <option value="HI">HI</option>
                                        <option value="IA">IA</option>
	                                    <option value="ID">ID</option>
	                                    <option value="IL">IL</option>
	                                    <option value="IN">IN</option>
	                                    <option value="KS">KS</option>
	                                    <option value="KY">KY</option>
	                                    <option value="LA">LA</option>
                                        <option value="MA">MA</option>
	                                    <option value="MD">MD</option>
                                        <option value="ME">ME</option>
	                                    <option value="MI">MI</option>
	                                    <option value="MN">MN</option>
	                                    <option value="MO">MO</option>
                                        <option value="MS">MS</option>
	                                    <option value="MT">MT</option>
                                        <option value="NC">NC</option>
                                        <option value="ND">ND</option>
	                                    <option value="NE">NE</option>
                                        <option value="NH">NH</option>
                                        <option value="NJ">NJ</option>
                                        <option value="NM">NM</option>
	                                    <option value="NV">NV</option>
	                                    <option value="NY">NY</option>
	                                    <option value="OH">OH</option>
	                                    <option value="OK">OK</option>
	                                    <option value="OR">OR</option>
	                                    <option value="PA">PA</option>
	                                    <option value="RI">RI</option>
	                                    <option value="SC">SC</option>
	                                    <option value="SD">SD</option>
	                                    <option value="TN">TN</option>
	                                    <option value="TX">TX</option>
	                                    <option value="UT">UT</option>
                                        <option value="VA">VA</option>
	                                    <option value="VT">VT</option>
	                                    <option value="WA">WA</option>
                                        <option value="WI">WI</option>
	                                    <option value="WV">WV</option>
	                                    <option value="WY">WY</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-lg-6">
                                    <input type="text" ng-model="customer2.Address2" ID="EditAddress2" class="form-control" placeholder="Address Line 2" />
                                </div>
                                <div class="col-lg-3">
                                    <input type="text" ng-model="customer2.Zip" ID="EditZip" class="form-control" placeholder="Zip" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <!-- Bottom left close button, reset -->
                        <button type="button" class="btn btn-default pull-left" data-dismiss="modal"
                                ng-click="abUtils.shallowClone(customer, customer2);">
                            Cancel
                        </button>
                        <!-- TODO -->
                        <button type="button" class="btn btn-default pull-left" disabled>
                            Make Inactive
                        </button>

                        <button type="button" class="btn btn-primary pull-right" data-dismiss="modal" 
                                ng-click="saveCustomerEdits();">
                            Save
                        </button>
                    </div>
                </div>
            </div>
        </div>

    </div>
    
    <script>
        $(function () {
            // Enable tabs
            $('#tabs-nav a').click(function (e) {
                e.preventDefault();
                $(this).tab('show');
            });
        });
    </script>

</asp:Content>