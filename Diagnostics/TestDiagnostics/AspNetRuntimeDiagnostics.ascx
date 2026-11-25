<%--  
Copyright (c) 2008 Gustavo G. Duarte (http://duartes.org/gustavo)

This file is licensed under the terms of the MIT/X11 open source license.
See copying.txt in the root directory of this project (above /src) or
http://en.wikipedia.org/wiki/MIT_License for the terms of copyright.
--%>

<%@ Control Language="C#" AutoEventWireup="true" Inherits="System.Web.UI.UserControl" %>
<%@ Import namespace="System.Collections.Generic"%>
<%@ Import namespace="System.Security.Principal"%>
<%@ Import namespace="System.Threading"%>
<%@ Import namespace="System.Globalization"%>
<%@ Import namespace="System.Diagnostics"%>
<%@ Import namespace="System.Reflection"%>

<script runat="server">
	private readonly StringBuilder m_sb = new StringBuilder(512);
	private static Dictionary<Type, Func<object,string>> m_formatters;
	
	private static void InitFormatters() {
		// there's a race condition here in that this could be called twice if there are two simultaneous hits
		// at start-up (fat chance). The race is harmless though, we just build the Dictionary twice.

		Dictionary<Type, Func<object, string>> formatters = new Dictionary<Type, Func<object, string>>();
		formatters[typeof (string[])] = DoObjectArray;
		formatters[typeof (IdentityReferenceCollection)] = DoWindowsGroups;
		formatters[typeof(FileVersionInfo)] = DoFileVersionInfo;

		m_formatters = formatters;
	}

	protected static string DoWindowsGroups(object objGroups) {
		IdentityReferenceCollection groups = (IdentityReferenceCollection)objGroups;

		StringBuilder groupHtml = new StringBuilder(groups.Count * 20);

		foreach (IdentityReference group in groups) {
			groupHtml.AppendFormat("{0}<br>", HttpUtility.HtmlEncode(group.Translate(typeof(NTAccount)).Value));
		}

		groupHtml.Length -= 4;
		return groupHtml.ToString();
	}	
	
	protected static string DoObjectArray(object objArray) {
		object[] array = (object[]) objArray;
		
		StringBuilder sb = new StringBuilder(array.Length*60);

		for (int i = 0; i < array.Length; i++) {
			sb.AppendFormat("[{0}]: {1}<br>", i, HttpUtility.HtmlEncode(array[i].ToString()));
		}

		sb.Length -= 4;
		return sb.ToString();
	}

	protected static string DoFileVersionInfo(object objFileVersionInfo) {
		FileVersionInfo fileVersionInfo = (FileVersionInfo) objFileVersionInfo;

		string fileName = HttpUtility.HtmlEncode(fileVersionInfo.FileName);
		string fileVersion = HttpUtility.HtmlEncode(fileVersionInfo.FileVersion);
		string fileDescription = HttpUtility.HtmlEncode(fileVersionInfo.FileDescription);
		string productName = HttpUtility.HtmlEncode(fileVersionInfo.ProductName);

		return string.Format("File: <span class='osPath'>{0}</span><br>File version: {1}<br>FileDescription: {2}<br>"
			+ "Product: {3}", fileName, fileVersion, fileDescription, productName);
	}
	

	protected static string StartTable() {
		return StartTable(string.Empty);
	}

	protected static string StartTable(string caption) {
		return @"
<div class='tableWrapper'>
	<span class='caption'>" + HttpUtility.HtmlEncode(caption) + @"</span>
	<table>
		<col width='50%' />
		<col width='50%' />
		<thead>
			<tr>
				<th>C# Page snippet + description</th>
				<th>Value</th>
			</tr>
		</thead>
		<tbody>
";
	}
	
	protected static string EndTable() {
		return @"
		</tbody>
	</table>
</div>";
	}

	protected void Add(object result, string csharpSnippet) {
		this.Add(result, csharpSnippet, string.Empty);
	}

	protected void Add(object result, string csharpSnippet, string description) {
		result = result ?? "null";
		
		if (null == m_formatters) {
			InitFormatters();
		}

		Type t = result.GetType();
		string formattedResult = m_formatters.ContainsKey(t) ? m_formatters[t](result) : HttpUtility.HtmlEncode(result.ToString());
		
		this.m_sb.Length = 0;

		this.m_sb.AppendFormat("<tr> <td><p>{0}</p>{1}</td> <td class='value'>{2}</td> </tr>", MsdnLinkFromSnippet(csharpSnippet), 
			description, formattedResult);

		this.Response.Write(this.m_sb.ToString());
	}

	private static readonly string[,] m_msdnSubstitutions = new string[,] {
		{ "AppDomain.CurrentDomain", "System.AppDomain"},
		{ "AppDomain.SetupInformation", "AppDomainSetup" },
		{ "Process.GetCurrentProcess().MainModule", "System.Diagnostics.ProcessModule"},
		{ "Process.GetCurrentProcess()", "System.Diagnostics.Process"},
		{ "this.Request.LogonUserIdentity", "System.Security.Principal.WindowsIdentity"},
		{ "this.Request.Url", "System.Uri"},
		{ "this.Request", "System.Web.HttpRequest"},
		{ "HttpRuntime", "System.Web.HttpRuntime"},
		{ "Environment", "System.Environment"},
		{ "Thread.CurrentThread", "System.Threading.Thread"},
		{ "this.Page.User.Identity", "System.Security.Principal.IIdentity"},
		{ "this.Page.MapPath(this.Page.AppRelativeVirtualPath)", "System.Web.UI.Page.MapPath"},
		{ "this.Page.TemplateSourceDirectory", "System.Web.UI.Control.TemplateSourceDirectory"},
		{ "this.Page", "System.Web.UI.TemplateControl"},
		{ "HttpContext.Current", "System.Web.HttpContext"},
	};
	
	protected static string MsdnLinkFromSnippet(string fullMemberName) {
		string msdnName = fullMemberName;
		
		for(int idx = 0; idx < m_msdnSubstitutions.GetLength(0); idx++) {
			msdnName = msdnName.Replace(m_msdnSubstitutions[idx,0], m_msdnSubstitutions[idx,1]);
		}
		
		return string.Format("<a href='http://msdn2.microsoft.com/en-us/library/{0}.aspx'>{1}</a>", 
			msdnName.ToLowerInvariant(), fullMemberName);
	}
	
	protected static string EquivalentTo(string snippet) {
		return "<i>Equivalent to</i> " + MsdnLinkFromSnippet(snippet);
	}

 </script>
<div class="aspNetDiagnostics">
<h2>HttpRequest information</h2>

<h3>HttpRequest.LogonUserIdentity and Process</h3>
	<p>
		When troubleshooting ASP.NET problems you often ask two questions: <b>which process is the code running in?</b>; and
		<b>which Windows user is it running as?</b> The default setups are thus:
	</p>
	<div class='tableWrapper'>
		<table>
			<thead>
				<tr>
					<th>Windows + IIS</th>
					<th>Worker Process</th>
					<th>ASP.NET threads</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td>Vista + IIS 7.0</td>
					<td>w3wp.exe running as NETWORK SERVICE, one per application pool</td>
					<td>IUSR, well-known account with SID S-1-5-17, see <a href='http://www.iis.net/1026/SinglePageArticle.ashx'>
						this post</a></td>
				</tr>
				<tr>
					<td>Windows 2003 + IIS 6.0</td>
					<td>w3wp.exe running as NETWORK SERVICE, one per application pool</td>
					<td>IUSR_MACHINE_NAME, per-machine anonymous IIS user</td>
				</tr>
				<tr>
					<td>Windows 2000/XP + IIS 5.0</td>
					<td>aspnet_wp.exe, one for all ASP.NET applications</td>
					<td>ASPNET, per-machine ASP.NET worker account</td>
				</tr>				
			</tbody>
		</table>
	</div>	
	<p>
		These defaults however are subject to many factors, so often you need to find the answers yourself. The cheat sheet
		below shows you the relevant classes and properties to use.
		<a href='http://www.microsoft.com/technet/sysinternals/FileAndDisk/processmonitor.mspx'>ProcessMonitor</a> is a great
		tool for troubleshooting Windows runtime problems, especially permission and access denied issues. If you wish to read up 
		on security and .NET, see Keith Brown's superb online book, <a href='http://www.pluralsight.com/wiki/default.aspx/Keith.GuideBook.HomePage'>
		The .NET Developer's Guide to Windows Security</a>.
	</p>
	
	<%= StartTable("HttpRequest.LogonUserIdentity And Process") %>
		<%
			Add(Environment.GetCommandLineArgs()[0], "Process.GetCurrentProcess().MainModule.FileName", 
				"GetCurrentProcess() has security demands and may not be available in certain situations. One work-around " +
				"is to use Environment.GetCommandLineArgs()[0] to at least get the file name");

			Add(Process.GetCurrentProcess().Id, "Process.GetCurrentProcess().Id",
				"The Windows process ID for the process running your code. This is the process you attach to for debugging, " +
				"watch for perf monitoring, and kill to restart your app 'cold'.");

			Add(Process.GetCurrentProcess().MainModule.FileVersionInfo, "Process.GetCurrentProcess().MainModule.FileVersionInfo");

			Add(Process.GetCurrentProcess().StartTime, "Process.GetCurrentProcess().StartTime");		
				
			Add(this.Request.LogonUserIdentity.AuthenticationType, "this.Request.LogonUserIdentity.AuthenticationType");
		
			Add(this.Request.LogonUserIdentity.Groups, "this.Request.LogonUserIdentity.Groups", 
				"These are the Windows groups which contain the user running your ASP.NET code.");

			Add(this.Request.LogonUserIdentity.Name, "this.Request.LogonUserIdentity.Name", 
				"This is the Windows user running your ASP.NET code. This user should be granted the permissions needed " +
				"by your application.");

			Add(this.Request.LogonUserIdentity.ImpersonationLevel, "this.Request.LogonUserIdentity.ImpersonationLevel",
				"This is 'Impersonation' if the thread running your code is impersonating a Windows user, otherwise it's 'None'. " +
				"In IIS 6 and 7, this is normally 'Impersonation' because the ASP.NET threads run under a different user than the " +
				"IIS worker process.");

			Add(this.Request.LogonUserIdentity.IsAnonymous, "this.Request.LogonUserIdentity.IsAnonymous");	

			Add(this.Request.LogonUserIdentity.IsSystem, "this.Request.LogonUserIdentity.IsSystem", 
				"True if your code is running as Local System. This should never be the case.");	

			Add(this.Request.LogonUserIdentity.User.Value, "this.Request.LogonUserIdentity.User.Value",
				"The <a href='http://en.wikipedia.org/wiki/Security_Identifier'>SID</a> for the account.");
		%>
<%= EndTable() %>

<h3>Paths</h3>
	<p>
		Path names in ASP.NET may be confusing, but the concepts are simple:
	</p>
	<ul>
		<li><b>Physical paths</b> refer to the server's filesystem (<i>e.g.</i>, <span class='techSnippet'>c:\inetpub\wwwroot\index.aspx</span>).</li>
		<li><b>Virtual paths</b> refer to HTTP paths, the stuff in the browser address bar.
		They come in two types: absolute and relative.</li>
		<li><b>Absolute</b> virtual paths are exactly what you see in the browser, 
		starting with the <span class='standOut'>/</span> after the host name (<i>e.g.</i>, <span class='techSnippet'>/gustavo/articles</span>). 
		</li>
		<li>
			<b>Relative</b> (or app-relative) virtual paths start with <span class='techSnippet'>~/</span>. The  
			<span class='techSnippet'>~/</span> is magic and always represents the root virtual path of your application. 
			So for an IIS application deployed at
			<span class='techSnippet'>/bunny/love/</span> ASP.NET transforms <span class='techSnippet'>~/</span> into
			<span class='techSnippet'>/bunny/love/</span>. If the app is deployed to the IIS root (<span class='techSnippet'>/</span>),
			then <span class='techSnippet'>~/</span> simply becomes <span class='techSnippet'>/</span>.
		</li>
	</ul>
	<p>
		There are two useful ASP.NET tools to manipulate paths. The <a href='http://msdn2.microsoft.com/en-us/library/system.web.httpserverutility.mappath.aspx'>
		HttpServerUtility.MapPath</a> method converts a virtual path to a physical path. The 
		<a href='http://msdn2.microsoft.com/en-us/library/system.web.virtualpathutility.aspx'>VirtualPathUtility</a> class has 
		several methods for manipulating virtual paths.
	</p>

<%= StartTable("HttpRequest and Page Paths") %>
		<% 
		Add(this.Request.ApplicationPath, "this.Request.ApplicationPath", "Gets the IIS root virtual path for " +
			"your ASP.net application. ASP.NET transforms ~/ into this value when making an absolute virtual path.");
		
		Add(this.Request.AppRelativeCurrentExecutionFilePath, "this.Request.AppRelativeCurrentExecutionFilePath",
			"Returns the app-relative virtual path for the <a href='http://msdn2.microsoft.com/en-us/library/system.web.ihttphandler.aspx'> " +
			"HttpHandler</a> currently executing, normally your page. " + EquivalentTo("this.Page.AppRelativeVirtualPath"));

		Add(this.Request.CurrentExecutionFilePath, "this.Request.CurrentExecutionFilePath",
			"Returns the absolute virtual path for the <a href='http://msdn2.microsoft.com/en-us/library/system.web.ihttphandler.aspx'> " +
			"HttpHandler</a> currently executing, normally your page.");
			
		Add(this.Request.PhysicalApplicationPath, "this.Request.PhysicalApplicationPath", "The root of your application in the server's file system.");

		Add(this.Request.PhysicalPath, "this.Request.PhysicalPath", "The file system location for the " +
			"<a href='http://msdn2.microsoft.com/en-us/library/system.web.ihttphandler.aspx'> " +
			"HttpHandler</a> currently executing, normally your page.");

		Add(this.Page.TemplateSourceDirectory, "this.Page.TemplateSourceDirectory");				
		%>
<%= EndTable() %>
	<p>
		<a href='/gustavo/blog/themes/gustavo/AspNetRuntimeDiagnostics.aspx'>Click here</a> for an 
		example where the ApplicationPath is not <span class='techSnippet'>/</span>.
	</p>

<h3>Request.Url</h3>
<%= StartTable() %>
		<%
		
		Add(this.Request.Url.AbsolutePath, "this.Request.Url.AbsolutePath");
		
		Add(this.Request.Url.AbsoluteUri, "this.Request.Url.AbsoluteUri");		

		Add(this.Request.Url.Authority, "this.Request.Url.Authority");		

		Add(this.Request.Url.DnsSafeHost, "this.Request.Url.DnsSafeHost");		

		Add(this.Request.Url.Fragment, "this.Request.Url.Fragment");		

		Add(this.Request.Url.Host, "this.Request.Url.Host");		

		Add(this.Request.Url.HostNameType, "this.Request.Url.HostNameType");		

		Add(this.Request.Url.LocalPath, "this.Request.Url.LocalPath");

		Add(this.Request.Url.OriginalString, "this.Request.Url.OriginalString");

		Add(this.Request.Url.PathAndQuery, "this.Request.Url.PathAndQuery");
		
		Add(this.Request.Url.Port, "this.Request.Url.Port");		
		
		Add(this.Request.Url.Query, "this.Request.Url.Query");		
		
		Add(this.Request.Url.Scheme, "this.Request.Url.Scheme");		
		
		Add(this.Request.Url.Segments, "this.Request.Url.Segments");								
		
		Add(this.Request.Url.UserInfo, "this.Request.Url.UserInfo");		
		%>
<%= EndTable() %>

<h3>Information from the HTTP request headers</h3>
<%= StartTable() %>
		<% 
		Add(this.Request.AnonymousID, "this.Request.AnonymousID", 
			"Used with ASP.NET <a href='http://www.odetocode.com/Articles/440.aspx'>anonymous profiles</a>.");
			
		Add(this.Request.ContentLength, "this.Request.ContentLength", "Length in bytes for the BODY in the client's request. For a GET request, "
			+ "this is normally zero as there is no body. For a POST request it depends on how much data is sent to the server.");

		Add(this.Request.TotalBytes, "this.Request.TotalBytes", "This is usually equal to ContentLength, but it could be slightly different "
			+ "depending on how the client encoded its HTTP request.");
		
		Add(this.Request.UrlReferrer, "this.Request.UrlReferrer", "The URL "
			+ "that sent the user your way. Bless them.");
		
		Add(this.Request.UserAgent, "this.Request.UserAgent", "The client's browser.");
		
		Add(this.Request.UserHostAddress, "this.Request.UserHostAddress");
		
		Add(this.Request.UserHostName, "this.Request.UserHostName");
		
		Add(this.Request.UserLanguages, "this.Request.UserLanguages", "User-configured language preferences "
			+ "sent by the browser. You might tune your content based on this.");
		%>
<%= EndTable() %>

<h2 id="environmentInformation">Environment</h2>
<%= StartTable() %>
		<%
		
		Add(Environment.OSVersion, "Environment.OSVersion");

		Add(Environment.WorkingSet, "Environment.WorkingSet", "Amount of physical memory used by the ASP.net worker process");
		
		Add(Thread.CurrentThread.CurrentCulture, "Thread.CurrentThread.CurrentCulture",
			"Used by string formatting and other culture-sensitive methods.");
		
		Add(Thread.CurrentThread.CurrentUICulture, "Thread.CurrentThread.CurrentUICulture",
			"Used by the ResourceManager to load culture-specific resources like strings and images	.");

		Add(Environment.UserDomainName, "Environment.UserDomainName");

		Add(Environment.UserName, "Environment.UserName", "Do <b>not</b> trust this value. Stick to HttpRequest.LogonUserIdentity");

		Add(Environment.Version, "Environment.Version", ".NET Framework version. This returns '2.0' even "
			+ "for assemblies compiled as .NET 3.5.");
		
		%>
<%= EndTable() %>

<h2>HttpContext</h2>
<%= StartTable() %>
		<%
		Add(HttpContext.Current.SkipAuthorization, "HttpContext.Current.SkipAuthorization");		
				
		Add(HttpContext.Current.User.Identity.AuthenticationType, "HttpContext.Current.User.Identity.AuthenticationType");

		Add(HttpContext.Current.User.Identity.IsAuthenticated, "HttpContext.Current.User.Identity.IsAuthenticated");

		Add(HttpContext.Current.User.Identity.Name, "HttpContext.Current.User.Identity.Name");
		
		Add(HttpContext.Current.Timestamp, "HttpContext.Current.Timestamp");
		%>
<%= EndTable() %>

<h2 id="httpRuntime">HttpRuntime and AppDomain</h2>
	<p>
		Your ASP.NET code runs inside a .NET <a href="http://www.odetocode.com/Articles/305.aspx">AppDomain</a>, which in turn runs inside a Windows
		process. The IIS version and configurations determine where your AppDomain will run. IIS 6 and 7 by default run AppDomains in a Worker Process called
		<span class='techSnippet'>w3wp.exe</span>. There is one worker process for each IIS <a href="http://www.developer.com/net/asp/article.php/2245511">
		application pool</a>. Inside the Worker Process, there is one AppDomain for each application in the pool. Here are some useful tidbits
		on the current AppDomain and process:
	</p>
<%= StartTable() %>
		<%
		Add(AppDomain.CurrentDomain.SetupInformation.ConfigurationFile, "AppDomain.CurrentDomain.SetupInformation.ConfigurationFile",
				"Configuration file for the current AppDomain. For ASP.net this is the web.config file.");
		
		Add(HttpRuntime.AppDomainAppId, "HttpRuntime.AppDomainAppId",
			"The /LM/W3SVC part is fixed for a given IIS instance. The following number is the Site ID within IIS. " +
			"The last piece is the " +
			"IIS root virtual path for the application (or 'ROOT' for /).");

		Add(HttpRuntime.AppDomainAppPath, "HttpRuntime.AppDomainAppPath", "The filesystem folder containing your application. " +
			EquivalentTo("AppDomain.CurrentDomain.BaseDirectory"));
		
		Add(HttpRuntime.AppDomainAppVirtualPath, "HttpRuntime.AppDomainAppVirtualPath");

		Add(HttpRuntime.AppDomainId, "HttpRuntime.AppDomainId", EquivalentTo("AppDomain.CurrentDomain.FriendlyName"));
		
		Add(HttpRuntime.AspClientScriptPhysicalPath, "HttpRuntime.AspClientScriptPhysicalPath");
		
		Add(HttpRuntime.AspClientScriptVirtualPath, "HttpRuntime.AspClientScriptVirtualPath");
		
		Add(HttpRuntime.AspInstallDirectory, "HttpRuntime.AspInstallDirectory");

		Add(HttpRuntime.BinDirectory, "HttpRuntime.BinDirectory", EquivalentTo("AppDomain.CurrentDomain.RelativeSearchPath"));

		Add(HttpRuntime.ClrInstallDirectory, "HttpRuntime.ClrInstallDirectory");

		Add(HttpRuntime.CodegenDir, "HttpRuntime.CodegenDir",
			"This is where ASP.NET stores generated source files for your pages, controls, etc. Watch this folder to see " +
			"what a processed page becomes. Pages are compiled to DLLs which are also stored here. " + 
			EquivalentTo("AppDomain.CurrentDomain.DynamicDirectory"));
		
		Add(HttpRuntime.MachineConfigurationDirectory, "HttpRuntime.MachineConfigurationDirectory");

		%>
<%= EndTable() %>


<h3>Loaded Assemblies</h3>
<p>
	.NET code is packaged into .NET <a href="http://msdn2.microsoft.com/en-us/library/hk5f40ct(VS.71).aspx">assemblies</a>. It 
	is often important to know which assemblies are loaded into your ASP.NET AppDomain because many problems boil down to 
	missing or incorrect assemblies. The method <%= MsdnLinkFromSnippet("AppDomain.CurrentDomain.GetAssemblies")%> returns
	a list of assemblies loaded in your AppDomain (it requires full trust). Here's the output for the current domain:
</p>

<p>
	Count of loaded assemblies: <b><%= AppDomain.CurrentDomain.GetAssemblies().Length %></b>
</p>
<div class='tableWrapper' style="max-height: 25em;">
<table style="width: 100%">
	<thead><tr><th>Assemblies</th></tr></thead>
	<tbody>
		<% foreach (Assembly a in AppDomain.CurrentDomain.GetAssemblies()) {%>
			<tr>
				<td>
					<p><%= HttpUtility.HtmlEncode(a.ManifestModule.FullyQualifiedName)%></p>
					<%= HttpUtility.HtmlEncode(a.FullName) %>
				</td>
			</tr>
		<% } %>
	</tbody>
</table>
</div>
</div>

