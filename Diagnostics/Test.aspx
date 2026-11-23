<%@ Page Title="ASP.NET Diagnostic Page" Language="C#" AutoEventWireup="true" Trace="true" TraceMode="SortByCategory" %>

<%@ Assembly Name="System.Security, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a" %> 

<%@ Import Namespace="System.Security.Principal" %>
<%@ Import Namespace="System.Security" %>
<%@ Import Namespace="System.Security.Permissions" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="System.Threading" %>

<script runat="server">

    protected void Page_Load(object sender, EventArgs e)  
    {  
    	lblVersion.Text = "Your server is running ASP.NET and the version is " + System.Environment.Version.ToString();
		GenerarTrazaDiagnostico();
    } 

	private void GenerarTrazaDiagnostico()
	{
		lbInfo.Text = "";
		
		string machineAddress = Request.UserHostAddress; 
		string machineName = Request.UserHostName; 
		
		lbInfo.Text += "Machine: ";
		lbInfo.Text += machineAddress;
		lbInfo.Text += " - "  + machineName;
		 
		lbInfo.Text += "<br/><br/>ASP.NET application executes using the identity :: <b>" + WindowsIdentity.GetCurrent().Name + "</b><br>";
		
		lbInfo.Text += "<br/>Page.User.Identity.Name: " + Page.User.Identity.Name;
		
		var wi = WindowsIdentity.GetCurrent();
		lbInfo.Text += "<br/><br/>WindowsIdentity.GetCurrent ";
		lbInfo.Text += "<br/>AuthenticationType: " + wi.AuthenticationType;
		
		lbInfo.Text += "<br/>Groups: ";
	 
		IdentityReferenceCollection irc = wi.Groups;
		foreach (IdentityReference ir in irc)
			lbInfo.Text += ", " + (ir.Value);


		lbInfo.Text += "<br/>ImpersonationLevel: " + wi.ImpersonationLevel;
		lbInfo.Text += "<br/>IsAnonymous: " + wi.IsAnonymous;
		lbInfo.Text += "<br/>IsAuthenticated: " + wi.IsAuthenticated;
		lbInfo.Text += "<br/>IsGuest: " + wi.IsGuest;
		lbInfo.Text += "<br/>IsSystem: " + wi.IsSystem;
		lbInfo.Text += "<br/>Name: " + wi.Name;
		lbInfo.Text += "<br/>Owner: " + wi.Owner;
		lbInfo.Text += "<br/>Token: " + wi.Token;
		lbInfo.Text += "<br/>User: " + wi.User;
		
		
		lbInfo.Text += "<br/><br/>Environment.UserName: " + System.Environment.UserName.ToString();
		
		lbInfo.Text += "<br/>Request.LogonUserIdentity.Name: " + Request.LogonUserIdentity.Name.ToString();
		// The server variable Auth_User is equivalent to User.Identity.Name when you are using Windows Authentication.
		lbInfo.Text += "<br/>ServerVariables[\"Auth_User\"]: " + Request.ServerVariables["Auth_User"];
		
					try
				{
			var user = Membership.GetUser();
			if (user == null)
			{
			lbInfo.Text += "<br/>Membership.GetUser(): NULO " ;
			}
			else
			{

				
				lbInfo.Text += "<br/>Membership.GetUser(): " + user.UserName;
				
			}
		  }
				catch (Exception ex)
				{
					lbInfo.Text += "<br/>Membership.GetUser(): Error " + ex.Message;
				}

		lbInfo.Text += "<br/><br/>HttpContext.Current.User";
		lbInfo.Text += "<br>Name: " + System.Web.HttpContext.Current.User.Identity.Name;
		lbInfo.Text += "<br>IsAuthenticated: " + System.Web.HttpContext.Current.User.Identity.IsAuthenticated;
		lbInfo.Text += "<br>AuthenticationType: " + System.Web.HttpContext.Current.User.Identity.AuthenticationType;
		
		
		
		IPrincipal threadPrincipal = System.Threading.Thread.CurrentPrincipal;
		
		lbInfo.Text += "<br/><br/>Thread.CurrentPrincipal<br/>" + string.Format("Name: {0}\nIsAuthenticated: {1}" +
				"\nAuthenticationType: {2}", 
				threadPrincipal.Identity.Name, 
				threadPrincipal.Identity.IsAuthenticated,
				threadPrincipal.Identity.AuthenticationType);
				
            
		if ((HttpContext.Current.User == null)) return;
	
		if (!HttpContext.Current.User.Identity.IsAuthenticated) return;
		if (HttpContext.Current.User.Identity.GetType() != typeof(FormsIdentity)) return;
			
				FormsIdentity fi = (FormsIdentity) HttpContext.Current.User.Identity;
				FormsAuthenticationTicket fat = fi.Ticket;

				String[] astrRoles = fat.UserData.Split('|');
				//HttpContext.Current.User = new GenericPrincipal(fi, astrRoles);
				
				lbInfo.Text += "<br/><br/>FormsAuthenticationTicket";
				lbInfo.Text += "<br/>CookiePath: " + fat.CookiePath;
				lbInfo.Text += "<br/>Expiration: " + fat.Expiration;
                lbInfo.Text += "<br/>Expired: " + fat.Expired;
                lbInfo.Text += "<br/>IsPersistent: " + fat.IsPersistent;
                lbInfo.Text += "<br/>IssueDate: " + fat.IssueDate;
                lbInfo.Text += "<br/>Name: " + fat.Name;
                lbInfo.Text += "<br/>UserData: " + fat.UserData;
                lbInfo.Text += "<br/>Version: " + fat.Version;
	
	}

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>ASP.NET Diagnostic Page</title>
</head>
<body>
    <form id="form1" runat="server">

    <h2>Version ASP.NET</h2>    
    <asp:Label ID="lblVersion" runat="server"></asp:Label>

	<h2>Diagn&oacute;stico ASP.NET</h2>   
	<p>
        <asp:label id="lbInfo" runat="server" style="background-color: White; color: Blue; font-weight: bold;" />
        <br /><br /><br />
     </p>
		
    <h2>Environment Variables</h2>
    <pre>
    <table>    
<%
        var variables = Environment.GetEnvironmentVariables();
        foreach (DictionaryEntry entry in variables)
        {
            Response.Write("<tr><td>");
            Response.Write(entry.Key);
            Response.Write("</td><td>");
            Response.Write(entry.Value);
            Response.Write("</td></tr>");
        }
    %>
    </table>
    </pre>

    <h2>Misc</h2>
    <pre>
    Response.Filter = <%= Request.Filter.ToString() %>
    Request.ApplicationPath = <%= Request.ApplicationPath %>
    Request.PhysicalApplicationPath = <%= Request.PhysicalApplicationPath %>
    Request.PhysicalPath = <%= Request.PhysicalPath %>
    Request.UrlReferrer = <%= Request.UrlReferrer %>
    Request.UserLanguages = <%= string.Join(",", (Request.UserLanguages ?? new string[0])) %>
    </pre>
    
    </form>
</body>
</html>
