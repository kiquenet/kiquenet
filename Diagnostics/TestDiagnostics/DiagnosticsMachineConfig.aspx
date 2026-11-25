<%@ Page Language="C#" Title="AspNetRuntimeDiagnostics" Trace="true" AutoEventWireup="True" ValidateRequest="false" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Security.Principal" %>
<%@ Import Namespace="System.Threading" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Security.Cryptography.X509Certificates" %>

<% //@ Import Namespace="Microsoft.Web.Administration" %>

<head id="Head1" runat="server" />

<script runat="server">

  
    protected void Page_Load(object sender, EventArgs e)
    {
        var Text = String.Format("This page uses ASP.NET {0}.{1}", Environment.Version.Major, Environment.Version.Minor);
        Response.Write(Text);
    }

</script>

<p></p>

<div>
    <hr align="left" width="30%" color="#04ACB5">
    <h2>IIS Data</h2>
    <hr align="left" width="30%" color="#04ACB5">

    <pre>
          Machine = <%= System.Runtime.InteropServices.RuntimeEnvironment.SystemConfigurationFile %>
          Machine = <%= System.Configuration.ConfigurationManager.OpenMachineConfiguration().FilePath %>
          Config = <%= System.Web.Configuration.WebConfigurationManager.OpenWebConfiguration("~").FilePath %>
          Environment Version = <%= Environment.Version %>
    </pre>

<div>
    <h2>Trace</h2>

</div>
