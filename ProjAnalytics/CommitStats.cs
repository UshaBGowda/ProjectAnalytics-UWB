using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ProjAnalytics
{
    public class CommitStats
    {
        public int Additions { get;  set; }
        //
        // Summary:
        //     The number of deletions made within the commit
        public int Deletions { get;  set; }
        //
        // Summary:
        //     The total number of modifications within the commit
        public int Total { get;  set; }
    }
}