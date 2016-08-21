using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using System.Web.Http.Description;
using AuditBench.Models;

namespace AuditBench.Controllers
{
    [RoutePrefix("api/classes")]
    public class ClassesController : IEntitiesController
    {
        // GET api/classes
        /// <summary>
        /// Get classes for the logged in vendor
        /// </summary>
        /// <returns>Classes</returns>
        public IQueryable<Models.@class> GetActive()
        {
            int? vendorID = ControllerUtil.GetVendorID();
            if (vendorID == null) return Enumerable.Empty<Models.@class>().AsQueryable();

            return db.classes.Where(c => c.classVendor == vendorID && c.Active == 1).OrderBy(c => c.className);
        }

        // GET /api/classes/erasure/
        /// <summary>
        /// Get the erasure enabled class data
        /// </summary>
        /// <returns></returns>
        [Route("erasure")]
        public IQueryable<object> GetErasureEnabled()
        {
            return GetActive().Where(c => c.ErasureImportEnabled).Select(c => new
            {
                classID = c.classID,
                className = c.className,
                mappings = from ms in db.Mappings where ms.classID == c.classID select new { ms.mappingID, ms.name }
            });
        }

        // GET api/classes/{id}
        /// <summary>
        /// Get the class for a logged in account with the given id
        /// </summary>
        /// <param name="id">classID</param>
        /// <returns></returns>
        [ResponseType(typeof(Models.@class))]
        public IHttpActionResult Get(int id)
        {
            var clss = GetActive().Where(c => c.classID == id).FirstOrDefault();
            if (clss == null) return NotFound();

            return Ok(clss);
        }
    }
}