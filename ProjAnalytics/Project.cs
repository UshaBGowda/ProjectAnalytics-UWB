using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ProjAnalytics
{
    public class Project
    {
        public int ID { get; set; }
        public string Name { get; set; }
        public string CloneURL { get; set; }
        public string DefaultBranch { get; set; }
        public DateTime CreatedDT { get; set; }
        public DateTime LastCommitDT { get; set; }

        public string Owner { get; set; }
    }
}