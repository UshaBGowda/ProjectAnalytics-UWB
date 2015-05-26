using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ProjAnalytics
{
    public class Commit
    {
        public string CommentsUrl { get;  set; }
        public User Committer { get;  set; }
        public File[] Files { get;  set; }
        public CommitStats Stats { get;  set; }

        public DateTime CommitDT { get; set; }
    }
}