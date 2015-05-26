using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ProjAnalytics
{
    public class UserProjects
    {
       
        public  Person Assignee { get; set; }

        public Person Modifier { get; set; }

        public int[] ProjectIDs { get; set; }

        public DateTime ModifiedDT { get; set; }

        public bool ActiveFlag { get; set; }
    }
}