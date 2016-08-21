using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using AuditBench.Controllers;
using AuditBench.Models;
using AuditBench.Views;
using static AuditBench.Views.NotificationView;

namespace AuditBench
{
    public partial class CustomerDetails : System.Web.UI.Page
    {

        protected void Page_Load(object sender, EventArgs e)
        {
            object vendorID = Session["VendorID"];
            if (!(vendorID is int))
            {
                NotificationDiv.Controls.Add(new NotificationView(NotificationType.DANGER, "You are not logged in!"));
                return;
            }

            int requestedVendorId;
            if (!Int32.TryParse(Request.QueryString["VendorID"], out requestedVendorId))
            {
                NotificationDiv.Controls.Add(new NotificationView(NotificationType.DANGER, "Invalid request"));
                return;
            }

            // Enable admin functionality
            if (User.IsInRole("Administrators"))
            {
                TopEditButton.Visible = true;
                InTabEditButton.Visible = true;
                EditNotesGroup.Visible = true;
            }
        }

        protected void SearchButton_Click(object sender, EventArgs e)
        {
            dsJobs.SelectParameters["JobNumber"] = new Parameter("JobNumber", TypeCode.String, SearchField.Value);
            dsJobs.DataBind();

            // SearchField.Value = "";
            SearchBackButton.Visible = true;
        }

        protected void SearchBackButton_ServerClick(object sender, EventArgs e)
        {
            dsJobs.SelectParameters["JobNumber"] = new Parameter("JobNumber", TypeCode.String, string.Empty);
            dsJobs.DataBind();
        
            SearchField.Value = "";
            SearchBackButton.Visible = false;
        }

        protected void dsJobs_Selecting(object sender, LinqDataSourceSelectEventArgs e)
        {
            // Find jobs for logged in customer of selected vendor
            object vendorID = e.SelectParameters["VendorID"];
            var jobs = (new JobsController()).GetCustomerJobs().Where(j => j.vendorID == (int?)vendorID);

            // Filter by job number
            object JobNumber = e.SelectParameters["JobNumber"];
            if (!string.IsNullOrWhiteSpace((string)JobNumber))
                jobs = jobs.Where(j => j.JobNumber.Contains((string) JobNumber));

            e.Result = jobs;
        }
    }
}