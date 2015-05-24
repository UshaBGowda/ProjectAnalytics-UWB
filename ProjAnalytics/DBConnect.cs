using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;

namespace ProjAnalytics
{
    public class DBConnect
    {
        private int _CommandTimeout = DEFAULT_COMMAND_TIMEOUT;

        private SqlConnectionStringBuilder _ConnectionStringManager;

        #region Constants
        private const int MAX_DEADLOCK_RETRIES = 3;
        private const int DEADLOCK_ERROR = 1205;
        private const int LOCK_WAIT_MILLIS = 250;
        private const int DEFAULT_COMMAND_TIMEOUT = 30;
        private const int DEFAULT_CONNECT_TIMEOUT = 5;
        #endregion


        public SqlConnectionStringBuilder ConnectionStringManager
        {
            get
            {
                return _ConnectionStringManager;
            }
        }


        public int CommandTimeout
        {
            get
            {
                return _CommandTimeout;
            }

            set
            {
                _CommandTimeout = value;
            }
        }



        public DBConnect()
        {
            _ConnectionStringManager = new SqlConnectionStringBuilder();
            _ConnectionStringManager.ConnectionString = ConfigurationManager.AppSettings["ConnectionString"];

        }


        /// -----------------------------------------------------------------------------
        /// <summary>
        /// Executes a stored procedure
        /// </summary>
        /// <param name="procedureName">the name of the stored procedure</param>
        /// <param name="parameters">an array of parameters to pass into the stored procedure</param>
        /// <returns>A DataTable containing the results from the stored procedure</returns>
        /// <remarks></remarks>
        ///-----------------------------------------------------------------------------
        public DataTable RunProcedureGetDataTable(string procedureName, params SqlParameter[] parameters)
        {
            return (DataTable)RunDbCommandImpl(procedureName, CommandType.StoredProcedure, parameters, new DbExecutor(ExecuteDataTable));
        }



        ///-----------------------------------------------------------------------------
        /// <summary>
        /// Generates a SQL parameter for use with this class
        /// </summary>
        /// <param name="parameterName">the name of the parameter</param>
        /// <param name="value">the value of the parameter</param>
        /// <returns>a SqlParameter object with the given values</returns>
        /// <remarks></remarks>
        ///-----------------------------------------------------------------------------
        public SqlParameter MakeParameter(string parameterName, object value)
        {
            return MakeParameter(parameterName, ParameterDirection.Input, 0, value);
        }

        public SqlParameter MakeParameter(string parameterName, ParameterDirection direction, int size, object value)
        {
            //assume null values are DBNull values or any MinValue
            Type valueType = value == null ? null : value.GetType();
            if (value == null)
            {
                value = DBNull.Value;
            }
            else if (valueType == typeof(Int16))
            {
                if ((Int16)value == Int16.MinValue)
                {
                    value = DBNull.Value;
                }
            }
            else if (valueType == typeof(Int32))
            {
                if ((Int32)value == Int32.MinValue)
                {
                    value = DBNull.Value;
                }
            }
            else if (valueType == typeof(Int64))
            {
                if ((Int64)value == Int64.MinValue)
                {
                    value = DBNull.Value;
                }
            }
            else if (valueType == typeof(DateTime))
            {
                if ((DateTime)value == DateTime.MinValue)
                {
                    value = DBNull.Value;
                }
            }
            else if (valueType == typeof(Char))
            {
                if ((Char)value == Char.MinValue)
                {
                    value = DBNull.Value;
                }
            }
            else if (valueType == typeof(Decimal))
            {
                if ((Decimal)value == Int32.MinValue)
                {
                    value = DBNull.Value;
                }
            }
            else if (valueType == typeof(Single))
            {
                if ((Single)value == Single.MinValue)
                {
                    value = DBNull.Value;
                }
            }
            else if (valueType == typeof(Double))
            {
                if ((Double)value == Double.MinValue)
                {
                    value = DBNull.Value;
                }
            }
            else if (valueType == typeof(Byte))
            {
                if ((Byte)value == Byte.MinValue)
                {
                    value = DBNull.Value;
                }
            }

            SqlParameter param = new SqlParameter(parameterName, value);
            param.Direction = direction;
            param.Size = size;
            return param;
        }

        ///-----------------------------------------------------------------------------
        /// <summary>
        /// Defines a template function for executing a SqlCommand.
        /// </summary>
        /// <param name="cmd">the SqlCommand to perform the opersion on</param>
        /// <returns>the result of the command being executed</returns>
        /// <remarks></remarks>
        ///-----------------------------------------------------------------------------
        private delegate object DbExecutor(SqlCommand cmd);



        ///-----------------------------------------------------------------------------
        /// <summary>
        /// Retrieves a datatable from the command object
        /// </summary>
        /// <param name="cmd">the SqlCommand to perform the opersion on</param>
        /// <returns>the result of the command being executed</returns>
        /// <remarks></remarks>
        ///-----------------------------------------------------------------------------
        private object ExecuteDataTable(SqlCommand cmd)
        {
            SqlDataAdapter adapter = new SqlDataAdapter(cmd);
            DataTable results = new DataTable();
            adapter.Fill(results);
            return results;
        }


        ///-----------------------------------------------------------------------------
        /// <summary>
        /// The main implementation of the DbConnect class. All public methods call this
        /// method to run the command.
        /// </summary>
        /// <param name="procedureName">The name of the stored procedure or the SQL to run</param>
        /// <param name="procedureType">The type of procedure that is to be run</param>
        /// <param name="parameters">parameters to pass into the command (optional)</param>
        /// <param name="runCommand">the delegate to execute the actual command</param>
        /// <returns>an object containing the result of the executed command</returns>
        /// <remarks>When making a public method of this, remember to cast the object to something
        /// more specific.</remarks>
        ///-----------------------------------------------------------------------------
        private object RunDbCommandImpl(string procedureName, CommandType procedureType, SqlParameter[] parameters, DbExecutor runCommand)
        {
            SqlCommand cmd = null;
            int numLockErrors = 0;

            cmd = CreateCommand(procedureName, procedureType, parameters);
        RunSp:

            try
            {
                DateTime start = DateTime.Now;
                cmd.Connection.Open();
                object result = runCommand(cmd);
                return result;
            }
            catch (SqlException e)
            {
                if (e.Number == DEADLOCK_ERROR)
                {
                    if (numLockErrors < MAX_DEADLOCK_RETRIES)
                    {
                        numLockErrors++;
                        System.Threading.Thread.Sleep(LOCK_WAIT_MILLIS);
                        goto RunSp;
                    }
                    else
                    {
                        throw e;
                    }
                }
                throw e;
            }
            catch (Exception e)
            {
                throw e;
            }
            finally
            {
                if (cmd != null && runCommand.Method.Name != "ExecuteReader")
                {
                    cmd.Connection.Close();
                }
            }
        }

        ///-----------------------------------------------------------------------------
        /// <summary>
        /// Creates a SqlComommand object using the given parameters and the class's
        /// connection string.
        /// </summary>
        /// <param name="procedureName">the name of the procedure/SQL string</param>
        /// <param name="procedureType">the type of the previous argument</param>
        /// <param name="parameters">the parameters to use for the command (optional)</param>
        /// <returns>a SqlCommand object</returns>
        /// <remarks></remarks>
        ///-----------------------------------------------------------------------------
        private SqlCommand CreateCommand(string procedureName, CommandType procedureType, SqlParameter[] parameters)
        {
            //Ensure that a ConnectionString has been set
            if (ConnectionStringManager.ConnectionString.Length == 0)
            {
                Exception ex = new Exception("A ConnectionString is required when calling a method.");
                throw ex;
            }

            //connection to data source
            SqlConnection connection = new SqlConnection(ConnectionStringManager.ConnectionString);
            SqlCommand command = new SqlCommand(procedureName, connection);
            command.CommandType = procedureType;
            command.CommandTimeout = CommandTimeout;
            if (parameters != null)
            {
                foreach (SqlParameter parameter in parameters)
                {
                    command.Parameters.Add(parameter);
                }
            }

            return command;
        }

        ///-----------------------------------------------------------------------------
        /// <summary>
        /// Builds a param string for debugging purposes
        /// </summary>
        /// <param name="parameters">the array of params to use</param>
        /// <returns>a name-value string of params</returns>
        /// <remarks></remarks>
        ///-----------------------------------------------------------------------------
        private string GetParamString(SqlParameter[] parameters)
        {
            StringBuilder builder = new StringBuilder();

            foreach (SqlParameter parameter in parameters)
            {
                builder.Append(parameter.ParameterName);
                builder.Append("='");
                if (parameter.Value == null || parameter.Value == DBNull.Value)
                {
                    builder.Append("<NULL>");
                }
                else
                {
                    builder.Append(parameter.Value.ToString());
                }
                builder.Append("' ");
            }

            return builder.ToString();
        }
    }
}
