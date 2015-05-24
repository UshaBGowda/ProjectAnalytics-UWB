using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;
using System.Data;

namespace ProjAnalytics
{
    [ServiceContract]
    public interface IUserService
    {
        [OperationContract]
        Person getPerson(int ID);

        [OperationContract]
        Person[] getPeopleDetails();

        [OperationContract]
        Person setPerson(Person newPerson);

        [OperationContract]
        bool deletePerson(int userID);
    }
}
