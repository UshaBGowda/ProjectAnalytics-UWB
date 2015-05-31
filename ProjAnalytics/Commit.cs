using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ProjAnalytics
{
    public class Commit
    {
        public string Comments { get;  set; }
        public User Committer { get;  set; }
        public File[] Files { get;  set; }
        public CommitStats Stats { get;  set; }

        public String SHA { get; set; }

        public DateTime CommitDT { get; set; }
    }
}