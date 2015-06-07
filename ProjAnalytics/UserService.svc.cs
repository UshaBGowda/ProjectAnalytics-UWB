//Webservice for Project manager analytical tool
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using System.IO;
using System.Xml.Serialization;
using System.Xml;
using Octokit;
using System.Threading.Tasks;
using System.Configuration;

namespace ProjAnalytics
{
      public class UserService : IUserService
    {
        private DBConnect _dbConnect = new DBConnect();
        asyncUtil _util = new asyncUtil();
        GitHubClient _github = new GitHubClient(new ProductHeaderValue("ProjAnalyticsApp"));
        
          //This function sets up configuraton to connect to github which connectd to github open API
        private GitHubClient initClient()
        {
            string strToken = ConfigurationManager.AppSettings["GitHubToken"];
            var credentials = new Credentials(strToken);
            
            var connection = new Octokit.Connection(new Octokit.ProductHeaderValue("ProjAnalyticsApp"))
            {
              Credentials = credentials
            };
            var octokitClient = new Octokit.GitHubClient(connection);
            return octokitClient;
        }


          //This function takes person object from UI and creates user information in database
        public Person setPerson(Person newPerson)
        {
            try
            {
                SqlParameter[] varParams = new SqlParameter[4];
                SqlParameter inputParam = new SqlParameter();
                GenericUtil<Person> Util = new GenericUtil<Person>();
                inputParam.Value = Util.SerializeToString(newPerson);
                inputParam.ParameterName = "@Input";
                varParams[0] = inputParam;
                Int32 retCode = -1;
                Int32 personID = -1;
                string ErrMsg = "";
                varParams[1] = new SqlParameter { ParameterName = "@Error_Message", Direction = ParameterDirection.Output, Value = ErrMsg };
                varParams[2] = new SqlParameter { ParameterName = "@PersonID", Direction = ParameterDirection.Output, Value = personID };
                varParams[3] = new SqlParameter { ParameterName = "@Return_Code", Direction = ParameterDirection.ReturnValue, Value = retCode };
                DataTable dt = _dbConnect.RunProcedureGetDataTable("spCreatePerson", varParams);
                ErrMsg = varParams[1].Value.ToString();
                personID = Int32.Parse(varParams[3].Value.ToString());
                retCode = Int32.Parse(varParams[3].Value.ToString());

                if (retCode == 0)
                {

                    Person pp = new Person
                    {
                        ID = int.Parse(dt.Rows[0]["ID"].ToString()),
                        FirstName = dt.Rows[0]["FirstName"].ToString(),
                        LastName = dt.Rows[0]["LastName"].ToString(),
                        LoginName = dt.Rows[0]["LoginName"].ToString(),
                        RoleID = Int32.Parse(dt.Rows[0]["RoleID"].ToString()),
                        Person_Address = new Address
                        {
                            Address1 = dt.Rows[0]["Address1"].ToString(),
                            Address2 = dt.Rows[0]["Address2"].ToString(),
                            City = dt.Rows[0]["City"].ToString(),
                            State = dt.Rows[0]["State"].ToString(),
                            ZIP = dt.Rows[0]["ZIP"].ToString()
                        }
                    };
                    return pp;
                }
                else
                {
                    throw new Exception(ErrMsg);
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message.ToString());
            }
        }



          //This funstion takes userID as the input parameter and deletes corresponding user record in database
        public bool deletePerson(int userID)
        {
            try
            {
                SqlParameter[] varParams = new SqlParameter[3];
                SqlParameter inputParam = new SqlParameter();
                GenericUtil<Person> Util = new GenericUtil<Person>();
                Int32 retCode = -1;
                string ErrMsg = "";
                varParams[0] = new SqlParameter { ParameterName = "@Input", Value = userID.ToString() };
                varParams[1] = new SqlParameter { ParameterName = "@Error_Message", Direction = ParameterDirection.Output, Value = ErrMsg };
                varParams[2] = new SqlParameter { ParameterName = "@Return_Code", Direction = ParameterDirection.ReturnValue, Value = retCode };
                DataTable dt = _dbConnect.RunProcedureGetDataTable("spDeletePerson", varParams);
                ErrMsg = varParams[1].Value.ToString();
                retCode = Int32.Parse(varParams[2].Value.ToString());

                if (retCode == 1)
                    return false;
                else
                    return true;

            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message.ToString());
            }
        }


          //This function takes userprojects object as the parameter which contains information about 
          //which projects to assign to user. The function thus stores the corresponding information in database
       public bool assignProjects(UserProjects usrPrjs)
        {
            try
            {
             
            SqlParameter[] varParams = new SqlParameter[3];
            SqlParameter inputParam = new SqlParameter();
            GenericUtil<UserProjects> Util = new GenericUtil<UserProjects>();
            inputParam.Value = Util.SerializeToString(usrPrjs);
            inputParam.ParameterName = "@Input";
            varParams[0] = inputParam;
            Int32 retCode = -1;
            string ErrMsg = "";
            varParams[1] = new SqlParameter { ParameterName = "@Error_Message", Direction = ParameterDirection.Output, Value = ErrMsg };
            varParams[2] = new SqlParameter { ParameterName = "@Return_Code", Direction = ParameterDirection.ReturnValue, Value = retCode };
            DataTable dt = _dbConnect.RunProcedureGetDataTable("spAssignProj", varParams);
            ErrMsg = varParams[1].Value.ToString();
            retCode = Int32.Parse(varParams[2].Value.ToString());

        if (retCode == 1)
                    return false;
                else
                    return true;

            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message.ToString());
            }
        }



          //This function takes userID and corresponding password as the arguments.
          //It then verifys the authentication for the user based on the password stored in database
        public bool verifyAuth(string userID, string password)
        {
            try
            {
                SqlParameter[] varParams = new SqlParameter[4];
                SqlParameter inputParam = new SqlParameter();
                GenericUtil<Person> Util = new GenericUtil<Person>();
                Int32 retCode = -1;
                string ErrMsg = "";
                varParams[0] = new SqlParameter { ParameterName = "@LoginName", Value = userID.ToString() };
                varParams[1] = new SqlParameter { ParameterName = "@Password", Value = password.ToString() };
                varParams[2] = new SqlParameter { ParameterName = "@Error_Message", Direction = ParameterDirection.Output, Value = ErrMsg };
                varParams[3] = new SqlParameter { ParameterName = "@Return_Code", Direction = ParameterDirection.ReturnValue, Value = retCode };
                DataTable dt = _dbConnect.RunProcedureGetDataTable("spLogin", varParams);
                ErrMsg = varParams[2].Value.ToString();
                retCode = Int32.Parse(varParams[3].Value.ToString());

                if (retCode != 0 || dt.Rows.Count == 0)
                    return false;
                else
                    return true;

            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message.ToString());
            }
        }


          //This function returns the list of users in the database
        public Person[] getPeopleDetails()
        {
            SqlParameter[] param = new SqlParameter[0];
            DataTable dt = _dbConnect.RunProcedureGetDataTable("sp_get", param);
            Person[] people = new Person[dt.Rows.Count];
            int i = 0;
            foreach (DataRow dr in dt.Rows)
            {
                Person pp = new Person
                {
                    ID = int.Parse(dr[0].ToString()),
                    FirstName = dr[1].ToString(),
                    LastName = dr[2].ToString(),
                    Person_Address = new Address
                    {
                        Address1 = dr[5].ToString(),
                        Address2 = dr[6].ToString(),
                        City = dr[7].ToString(),
                        State = dr[8].ToString(),
                        ZIP = dr[9].ToString()
                    }
                };
                people[i] = pp;
                i++;
            }
            return people;
        }



          //This function returns list of commits for a particular project name, project owner and branch name
       public Commit[] getCommits(string ProjectName, string ProjectOwner, string BranchName)
        {
            
            List<Commit> commits = new List<Commit>();
            try
            {
                 GitHubClient client = initClient();
                 RepositoryCommitsClient repComClient = new RepositoryCommitsClient(
                     new ApiConnection(client.Connection));
                                CommitRequest commReq = new CommitRequest();
                commReq.Sha = BranchName;
               
                var result1 = _util.getCommits(repComClient, ProjectOwner, ProjectName, commReq);
                var result = result1.Result;
                foreach(GitHubCommit gC in result)
                {
                    Commit objCommit = new Commit();
                    objCommit.CommitDT = DateTime.Now;
                    objCommit.Comments = gC.Commit.Message;
                    objCommit.SHA = gC.Sha.ToString();
                    if (gC.Committer != null)
                    {
                        objCommit.Committer = new User { Login = gC.Committer.Login, ID = gC.Committer.Id, AvatarURL = gC.Committer.AvatarUrl };
                    }
                    List<File> files = new List<File>();
                    if (gC.Files != null)
                    {
                        foreach (GitHubCommitFile ghcFile in gC.Files)
                        {
                            File objFile = new File
                            {
                                Additions = ghcFile.Additions,
                                Changes = ghcFile.Changes,
                                Deletions = ghcFile.Deletions,
                                Filename = ghcFile.Filename,
                                RawUrl = ghcFile.RawUrl,
                                Status = ghcFile.Status
                            };
                            files.Add(objFile);
                        }
                    }
                    if (gC.Stats != null)
                    {
                        objCommit.Stats = new CommitStats
                        {
                            Additions = gC.Stats.Additions,
                            Deletions = gC.Stats.Deletions,
                            Total = gC.Stats.Total
                        };
                    }
                    objCommit.Files=files.ToArray();
                    commits.Add(objCommit);
    
                    }
                
                return commits.ToArray();
            }
           catch( Exception ex)
            {
                return commits.ToArray();
            }
        }


          //This function returns list of commits done by a developer given project name, branch name and project owner
       public Commit[] getDeveloperCommits(string ProjectName, string ProjectOwner, string BranchName, string devLoginName)
       {

           List<Commit> commits = new List<Commit>();
           try
           {
               GitHubClient client = initClient();
               RepositoryCommitsClient repComClient = new RepositoryCommitsClient(
                   new ApiConnection(client.Connection));
               CommitRequest commReq = new CommitRequest();
               commReq.Sha = BranchName;

               var result1 = _util.getCommits(repComClient, ProjectOwner, ProjectName, commReq);
               var result = result1.Result;
               foreach (GitHubCommit gC in result)
               {
                   if (gC.Committer != null && gC.Committer.Login == devLoginName)
                   {
                       Commit objCommit = new Commit();
                       objCommit.CommitDT = DateTime.Now;
                       objCommit.Comments = gC.Commit.Message;
                       objCommit.SHA = gC.Sha.ToString();
                       if (gC.Committer != null)
                       {
                           objCommit.Committer = new User { Login = gC.Committer.Login, ID = gC.Committer.Id, AvatarURL = gC.Committer.AvatarUrl };
                       }
                       List<File> files = new List<File>();
                       if (gC.Files != null)
                       {
                           foreach (GitHubCommitFile ghcFile in gC.Files)
                           {
                               File objFile = new File
                               {
                                   Additions = ghcFile.Additions,
                                   Changes = ghcFile.Changes,
                                   Deletions = ghcFile.Deletions,
                                   Filename = ghcFile.Filename,
                                   RawUrl = ghcFile.RawUrl,
                                   Status = ghcFile.Status
                               };
                               files.Add(objFile);
                           }
                       }
                       if (gC.Stats != null)
                       {
                           objCommit.Stats = new CommitStats
                           {
                               Additions = gC.Stats.Additions,
                               Deletions = gC.Stats.Deletions,
                               Total = gC.Stats.Total
                           };
                       }
                       objCommit.Files = files.ToArray();
                       commits.Add(objCommit);
                   }

               }

               return commits.ToArray();
           }
           catch (Exception ex)
           {
               return commits.ToArray();
           }
       }


          //This function lists all the contributors given project name and project owner
        public User[] getContributors(string ProjectName, string ProjectOwner)
        {
            List<User> Users = new List<User>();
            try
            {
                var contributors = _util.getContributors(new RepositoriesClient(new ApiConnection(new Connection(new ProductHeaderValue("Nothing"), new Uri("https://api.github.com/")))), ProjectOwner, ProjectName).Result;
                foreach(RepositoryContributor repC in contributors)
                {
                    Users.Add(new User
                    {
                        AvatarURL = repC.AvatarUrl,
                        ID = repC.Id,
                        Login = repC.Login
                    });
                }
                return Users.ToArray();
            }
            catch(Exception ex)
            {
                string errMsg = ex.Message.ToString();
                return Users.ToArray(); ;//.ToList<Repository>();
            }

        }

          //This function gives details of Individual commit
        public Commit getCommitDetails(Commit commitObj,Project projectObj)
        {
          try{
                 GitHubClient client = initClient();
                 RepositoryCommitsClient repComClient = new RepositoryCommitsClient(
                     new ApiConnection(client.Connection));
             


                  var result1 = _util.getCommit(repComClient,projectObj.Owner,projectObj.Name,commitObj.SHA);
                  var result = result1.Result;
                  List<File> files = new List<File>();

              foreach (GitHubCommitFile ghcFile in result.Files)
              {
                  File fl = new File
                  {
                      Additions = ghcFile.Additions,
                      Changes = ghcFile.Changes,
                      Deletions = ghcFile.Deletions,
                      Filename = ghcFile.Filename,
                      RawUrl = ghcFile.RawUrl,
                      Status = ghcFile.Status
                  };
                  files.Add(fl);
              }
              commitObj.Files = files.ToArray<File>();
              commitObj.Comments = result.Commit.Message;
              commitObj.CommitDT = DateTime.Now;
              commitObj.Committer = new User
              {
                  AvatarURL = result.Committer.AvatarUrl,
                  ID = result.Committer.Id,
                  Login = result.Committer.Login
              };
              commitObj.SHA = result.Sha.ToString();
              commitObj.Stats = new CommitStats
              {
                  Additions = result.Stats.Additions,
                  Deletions = result.Stats.Deletions,
                  Total = result.Stats.Total
              };
              return commitObj;
            }
            catch (Exception ex)
            {
                return new Commit();
            }
        }


          //This function lists the projects assigned for user
        public Project[] getProjects(int personID)
        {
            Project[] repos = new Project[3];
            try
            {

                SqlParameter[] varParams = new SqlParameter[3];
                SqlParameter inputParam = new SqlParameter();
                GenericUtil<Person> Util = new GenericUtil<Person>();
                Int32 retCode = -1;
                string ErrMsg = "";
                varParams[0] = new SqlParameter { ParameterName = "@personID", Value = personID.ToString() };
                varParams[1] = new SqlParameter { ParameterName = "@Error_Message", Direction = ParameterDirection.Output, Value = ErrMsg };
                varParams[2] = new SqlParameter { ParameterName = "@Return_Code", Direction = ParameterDirection.ReturnValue, Value = retCode };
                DataTable dt = _dbConnect.RunProcedureGetDataTable("spGetProjects", varParams);
                ErrMsg = varParams[1].Value.ToString();
                retCode = Int32.Parse(varParams[2].Value.ToString());

                int i = 0;
                if (retCode == 0)
                {

                    foreach (DataRow dr in dt.Rows)
                    {

                        string projName = dt.Rows[i][1].ToString();

                        var searchRepositoriesRequest = new SearchRepositoriesRequest(projName);

                         if(projName.ToLower().Contains("octokit") || projName.ToLower().Contains("project"))
                         {
                             searchRepositoriesRequest.Language = Language.CSharp;
                         }
                             searchRepositoriesRequest.Order = SortDirection.Descending;
                             searchRepositoriesRequest.PerPage = 10;
                         
                        var result = _util.getRepos(_github, searchRepositoriesRequest).Result.Items[0];
                        repos[i] = new Project
                        {
                            CloneURL = result.CloneUrl,
                            CreatedDT = result.CreatedAt.ToLocalTime().DateTime,
                            DefaultBranch = result.DefaultBranch,
                            ID = result.Id,
                            LastCommitDT = result.PushedAt.Value.ToLocalTime().DateTime,
                            Name = result.Name,
                            Owner = result.Owner.Login
                        };
                        i++;

                    }
                    return repos;
                }
                else
                {
                    throw new Exception(ErrMsg);
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message.ToString());

            }
        }
                
    
                
          //Utility class to serialize 
        public class GenericUtil<T>
        {

            public string SerializeToString(T value)
            {
                var emptyNamepsaces = new XmlSerializerNamespaces(new[] { XmlQualifiedName.Empty });
                var serializer = new XmlSerializer(value.GetType());
                var settings = new XmlWriterSettings();
                settings.Indent = true;
                settings.OmitXmlDeclaration = true;

                using (var stream = new StringWriter())
                using (var writer = XmlWriter.Create(stream, settings))
                {
                    serializer.Serialize(writer, value, emptyNamepsaces);
                    return stream.ToString();
                }
            }
        }

        class asyncUtil
        {
            public async Task<SearchRepositoryResult> getRepos(GitHubClient github, SearchRepositoriesRequest searchRepositoriesRequest)
            {
                SearchRepositoryResult searchRepositoryResult = await (github.Search.SearchRepo(searchRepositoriesRequest));
                //var user = await github.User.Get("ushaBgowda");
                return searchRepositoryResult;
            }

            public async Task<Branch> getBranch(GitHubClient github, string owner, string name, string branchName)
            {
                try
                {
                    Branch searchRepositoryResult = await (github.Repository.GetBranch(owner, name, branchName));

                    //var user = await github.User.Get("ushaBgowda");
                    return searchRepositoryResult;
                }
                catch (Exception ex)
                {
                    string err = ex.Message.ToString();
                    return new Branch();
                }
            }

            public async Task<IEnumerable<GitHubCommit>> getCommits(RepositoryCommitsClient repoClient, string owner, string name, CommitRequest commReq)
            {
                IEnumerable<GitHubCommit> commits = null;
                try
                {
                    commits = await repoClient.GetAll(owner, name, commReq);
                    //var user = await github.User.Get("ushaBgowda");
                    return commits;
                }
                catch (Exception ex)
                {
                    string err = ex.Message.ToString();
                    return commits;
                }
            }

            public async Task<GitHubCommit> getCommit(RepositoryCommitsClient repoClient, string owner, string name, string sha)
            {
                GitHubCommit commit = null;
                try
                {
                    commit = await repoClient.Get(owner, name, sha);
                    
                    //var user = await github.User.Get("ushaBgowda");
                    return commit;
                }
                catch (Exception ex)
                {
                    string err = ex.Message.ToString();
                    return commit;
                }
            }

            public async Task<IEnumerable<RepositoryContributor>> getContributors(RepositoriesClient repoClient, string owner, string name)
            {
                IEnumerable<RepositoryContributor> con = null;
                try
                {
                    con = await repoClient.GetAllContributors(owner, name);

                    //var user = await github.User.Get("ushaBgowda");
                    return con;
                }
                catch (Exception ex)
                {
                    string err = ex.Message.ToString();
                    return con;
                }
            }
        }
    }
}
