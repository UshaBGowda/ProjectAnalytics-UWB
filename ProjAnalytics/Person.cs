using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Web;

namespace ProjAnalytics
{
    public class Person
    {
        public int ID{ get; set; }
        public string FirstName{ get; set; }
        public string LastName{ get; set; }

        public int RoleID { get; set; }

        public string EmailAddress { get; set; }

        public string userPassword { get; set; }

        public Address Person_Address{ get; set; }
        public string LoginName { get; set; }
    }
}