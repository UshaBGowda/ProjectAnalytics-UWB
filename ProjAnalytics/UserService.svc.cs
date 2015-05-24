//Fourth Checkin
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

namespace ProjAnalytics
{
    // NOTE: You can use the "Rename" command on the "Refactor" menu to change the class name "UserService" in code, svc and config file together.
    // NOTE: In order to launch WCF Test Client for testing this service, please select UserService.svc or UserService.svc.cs at the Solution Explorer and start debugging.
    public class UserService : IUserService
    {
        private DBConnect _dbConnect = new DBConnect();
        public Person getPerson(int ID)
        {
            Person p = new Person();
            SqlParameter[] param = new SqlParameter[0];
            DataTable dt = _dbConnect.RunProcedureGetDataTable("sp_get", param);
            return p;
        }

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
                // varParams[0] = new SqlParameter{ParameterName="@Input",Value=stringwriter.ToString()};
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
                        ID = int.Parse(dt.Rows[0][0].ToString()),
                        FirstName = dt.Rows[0][1].ToString(),
                        LastName = dt.Rows[0][2].ToString(),
                        Person_Address = new Address
                        {
                            Address1 = dt.Rows[0][5].ToString(),
                            Address2 = dt.Rows[0][6].ToString(),
                            City = dt.Rows[0][7].ToString(),
                            State = dt.Rows[0][8].ToString(),
                            ZIP = dt.Rows[0][9].ToString()
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
    }
}
