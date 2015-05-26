using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;
using System.Data;
using Octokit;

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

        [OperationContract]
        bool verifyAuth(string userID, string password);

        [OperationContract]
        Project[] getProjects(int personID);


        [OperationContract]
        User[] getContributors(string ProjectName, string ProjectOwner);

        [OperationContract]
        Commit[] getCommits(string ProjectName, string ProjectOwner, string BranchName);

        [OperationContract]
        bool assignProjects(UserProjects usrPrjs);

        [OperationContract]
        Commit[] getDeveloperCommits(string ProjectName, string ProjectOwner, string BranchName, string devLoginName);
    }
}
