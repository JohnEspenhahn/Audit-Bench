using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;
using System.Text.RegularExpressions;
using System.Data;
using System.Web.Script.Serialization;
using System.Text;
using AuditBench.Models;
using System.Data.Entity.Infrastructure;
using Microsoft.AspNet.Identity;
using AuditBench.Controllers;
using AuditBench.Views;
using static AuditBench.Views.NotificationView;

namespace AuditBench
{
    public partial class QuickAudit : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            int receiptID;
            if (!(Session["VendorID"] is int))
            {
                NotificationDiv.Controls.Add(new NotificationView(NotificationType.DANGER, "There was an error with your session. Please re-loggin!"));
                return;
            }
            else if (!Int32.TryParse(Request.QueryString["receiptID"], out receiptID))
            {
                NotificationDiv.Controls.Add(new NotificationView(NotificationType.DANGER, "Invalid request!"));
                return;
            }

            // Load job details
            using (JobsController jobs = new JobsController())
            {
                var job = jobs.SelectJobByReceiptID(receiptID);
                if (job == null)
                {
                    NotificationDiv.Controls.Add(new NotificationView(NotificationType.DANGER, "Invalid request!"));
                    return;
                }

                JobNumber2.InnerText = JobNumber.InnerText = job.JobNumber;
                ReceiptNumber2.InnerText = ReceiptNumber.InnerText = job.ReceiptNumber;
                PlantName2.InnerText = PlantName.InnerText = job.PlantName;
            }

            // Enable editing for administrators
            if (User.IsInRole("Administrators"))
            {
                EditManufacturerDiv.Visible = true;
                EditModelNameDiv.Visible = true;
                EditModelNumberDiv.Visible = true;
            }
        }

        protected void dsClasses_Selecting(object sender, LinqDataSourceSelectEventArgs e)
        {
            e.Result = (new ClassesController()).GetActive();
        }
    }
}