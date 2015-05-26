using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ProjAnalytics
{
    public class File
    {
        // Summary:
        //     Number of additions performed on the file.
        public int Additions { get;  set; }
        //
        // Summary:
        //     Number of changes performed on the file.
        public int Changes { get;  set; }
        //
        // Summary:
        //     Number of deletions performed on the file.
        public int Deletions { get;  set; }
        //
        // Summary:
        //     The name of the file
        public string Filename { get;  set; }
        // Summary:
        //     The raw url to download the file.
        public string RawUrl { get;  set; }
        // Summary:
        //     File status, like modified, added, deleted.
        public string Status { get;  set; }
    }
}