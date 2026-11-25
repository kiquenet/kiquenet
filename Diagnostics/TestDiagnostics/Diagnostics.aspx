<%@ Page Language="C#" Title="AspNetRuntimeDiagnostics" Trace="true" AutoEventWireup="True" ValidateRequest="false" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Security.Principal" %>
<%@ Import Namespace="System.Threading" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Security.Cryptography.X509Certificates" %>
<%@ Import Namespace="System.Runtime.InteropServices" %>

<% //@ Import Namespace="Microsoft.Web.Administration" %>

<head id="Head1" runat="server" />

<script runat="server">

    private const int GEOCLASS_NATION = 16;

    //SYSGEOTYPE
    private const int GEO_NATION = 1;
    private const int GEO_LATITUDE = 2;
    private const int GEO_LONGITUDE = 3;
    private const int GEO_ISO2 = 4;
    private const int GEO_ISO3 = 5;
    private const int GEO_RFC1766 = 6;
    private const int GEO_LCID = 7;
    private const int GEO_FRIENDLYNAME = 8;
    private const int GEO_OFFICIALNAME = 9;
    private const int GEO_TIMEZONES = 10;
    private const int GEO_OFFICIALLANGUAGES = 11;

    //[DllImport("kernel32.dll", ExactSpelling = true, CallingConvention = CallingConvention.StdCall, SetLastError = true)]
    //private static extern int GetUserGeoID(GeoClass geoClass);

    [DllImport("kernel32.dll")]
    static extern int GetUserGeoID(int geoId);

    [DllImport("kernel32.dll")]
    private static extern int GetUserDefaultLCID();

    [DllImport("kernel32.dll")]
    private static extern int GetGeoInfo(int geoid, int geoType, StringBuilder lpGeoData, int cchData, int langid);

    private string GetGeoFriendlyName(int geoId)
    {
        int lcid = GetUserDefaultLCID();
        StringBuilder bldr = new StringBuilder(50);
        GetGeoInfo(geoId, GEO_FRIENDLYNAME, bldr, bldr.Capacity, lcid);
        return bldr.ToString();
    }

    private string GetGeoIso2(int geoId)
    {
        int lcid = GetUserDefaultLCID();
        StringBuilder bldr = new StringBuilder(50);
        GetGeoInfo(geoId, GEO_ISO2, bldr, bldr.Capacity, lcid);
        return bldr.ToString();
    }


    public X509Certificate2Collection Certificates;

    protected void Page_Load(object sender, EventArgs e)
    {
        // Local Computer\Personal 
        var store = new X509Store(StoreLocation.LocalMachine);
        // create and open store for read-only access 
        store.Open(OpenFlags.ReadOnly);
        Certificates = store.Certificates;
        repeater1.DataSource = Certificates;
        repeater1.DataBind();

        BindDataBInfo();
        BindDataHeaders();

        //Microsoft .NET Framework 1.0 (no service pack) 1.0.3705.000
        //Microsoft .NET Framework 1.0 Service Pack 1 (SP1) 1.0.3705.209
        //Microsoft .NET Framework 1.0 Service Pack 2 (SP2) 1.0.3705.288
        //Microsoft .NET Framework 1.0 Service Pack 3 (SP3) 1.0.3705.6018

        string servicePack = "";
        if (Environment.Version.Build == 3705)
        {
            switch (Environment.Version.Revision)
            {
                case 209:
                    servicePack = "SP1";
                    break;
                case 288:
                    servicePack = "SP1";
                    break;
                case 6018:
                    servicePack = "SP1";
                    break;
            }
        }
        else if (Environment.Version.Build == 4322)
        {
            using (
            Microsoft.Win32.RegistryKey regKey = Microsoft.Win32.Registry.LocalMachine.OpenSubKey(@"Software\Microsoft\NETFramework Setup\NDP\v1.1.4322"))
            {
                if (regKey.GetValue("SP").ToString() == "1")
                    servicePack = "SP1";
            }
        }

        //HKEY_LOCAL_MACHINE\Software\Microsoft\NET FrameworkSetup\NDP\v1.1.4322
        var Text = String.Format("This page uses ASP.NET {0}.{1} {2}", Environment.Version.Major, Environment.Version.Minor, servicePack);
        Response.Write(Text);

    }

    // https://weblog.west-wind.com/posts/2007/Jun/29/HttpWebRequest-and-GZip-Http-Responses
    public static bool IsGZipSupported()
    {
        string AcceptEncoding = HttpContext.Current.Request.Headers["Accept-Encoding"];
        if (!string.IsNullOrEmpty(AcceptEncoding) &&
             (AcceptEncoding.Contains("gzip") || AcceptEncoding.Contains("deflate")))
            return true;
        return false;
    }

    private void BindDataBInfo()
    {
        System.Web.HttpBrowserCapabilities browser = Request.Browser;
        Literal1.Text = "<table border=\"1\" cellspacing=\"3\" cellpadding=\"2\">";
        foreach (string key in browser.Capabilities.Keys)
        {
            Literal1.Text += "<tr><td>" + key + "</td><td>" + browser[key] + "</tr>";
        }
        Literal1.Text += "</table>";
        browser = null;
    }

    private void BindDataHeaders()
    {
        var headers = String.Empty;
        Literal2.Text = "<table border=\"1\" cellspacing=\"3\" cellpadding=\"2\">";
        foreach (var key in Request.Headers.AllKeys)
            Literal2.Text += "<tr><td>" + key + "</td><td>" + Request.Headers[key] + "</tr>";
        Literal2.Text += "</table>";
    }


    public class Extensions
    {
        public static string HasPublicKeyAccess(X509Certificate2 cert)
        {
            try
            {
                AsymmetricAlgorithm algorithm = cert.PublicKey.Key;
            }
            catch (Exception ex)
            {
                return "No";
            }
            return "Yes";
        }
        public static string HasPrivateKeyAccess(X509Certificate2 cert)
        {
            try
            {
                string algorithm = cert.PrivateKey.KeyExchangeAlgorithm;
            }
            catch (Exception ex)
            {
                return "No";
            }
            return "Yes";
        }
    }

    //  Microsoft.Web.Administration namespace. You can get this from NuGet or from %WinDir%\System32\InetSrv\Microsoft.Web.Administration.dll 
    //var serverManager = new ServerManager();
    //var appPool = serverManager.ApplicationPools[0]; // get appPool by Index or by appPoolName
    //var managedPipelineMode = appPool.ManagedPipelineMode;

    private System.Web.Configuration.TrustSection GetTrustSection()
    {
        var config = System.Web.Configuration.WebConfigurationManager.OpenWebConfiguration("~");
        var configSection = (System.Web.Configuration.TrustSection)config.GetSection("system.web/trust");
        return configSection;
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
          UsingIntegratedPipeline = <%= System.Web.HttpRuntime.UsingIntegratedPipeline  %>
          trust LegacyCasModel = <%= GetTrustSection().LegacyCasModel  %>
          trust Level = <%= GetTrustSection().Level  %>
          trust OriginUrl = <%= GetTrustSection().OriginUrl  %>

          HttpRuntime.TargetFramework  : <%= System.Web.HttpRuntime.TargetFramework %>
          BuildManager.TargetFramework : <%= System.Web.Compilation.BuildManager.TargetFramework %>
          <%
              var targetFramework = "Unknown";
              var targetFrameworkAttributes = Assembly.GetExecutingAssembly().GetCustomAttributes(typeof(System.Runtime.Versioning.TargetFrameworkAttribute), true);
              if (targetFrameworkAttributes.Length > 0)
              {
                  var targetFrameworkAttribute = (System.Runtime.Versioning.TargetFrameworkAttribute)targetFrameworkAttributes.First();
                  targetFramework = (targetFrameworkAttribute.FrameworkName) + " FrameworkDisplayName: (" + (targetFrameworkAttribute.FrameworkDisplayName) + ")";
              }
          Response.Write("TargetFramework: " + targetFramework);
         %>
    </pre>

    <p>
        <a href="AspNetDiagnostics.aspx">AspNet Diagnostics Details</a>
    </p>

    <hr align="left" width="30%" color="#04ACB5">
    <h2>Localization - Globalization - Culture - Region</h2>
    <hr align="left" width="30%" color="#04ACB5">

    <pre>
        Request.UserLanguages = <%= string.Join(",", (Request.UserLanguages ?? new string[0])) %>  ***** Accept-Language = <%= Request.Headers["Accept-Language"] %>

        <%
            // HKEY_CURRENT_USER\Control Panel\International\Geo"
            using (var regKeyGeo = Microsoft.Win32.Registry.CurrentUser.OpenSubKey(@"Control Panel\International\Geo"))
            {
                var NationValue = Convert.ToInt32(regKeyGeo.GetValue("Nation").ToString());

                int geoId = GetUserGeoID(GEOCLASS_NATION);
                string friendlyName = GetGeoFriendlyName(geoId);
                Response.Write("GetUserGeoID: " + geoId + " - friendlyName: " + friendlyName + @". HKEY_CURRENT_USER\Control Panel\International\Geo - Nation: " + NationValue + " - " + GetGeoFriendlyName(NationValue));

                var iso2 = GetGeoIso2(geoId);
                Response.Write(" - GetGeoIso2: " + iso2);

                var regionGeo = new RegionInfo(iso2);
                Response.Write(" - " + regionGeo.DisplayName + " - " + regionGeo.ISOCurrencySymbol);

                var cultureInfo = CultureInfo.GetCultures(CultureTypes.AllCultures).Where(c => c.Name.EndsWith(iso2));
                var cultureList = cultureInfo.ToList();
                foreach (System.Globalization.CultureInfo culture in cultureList)
                {
                    Response.Write("<br /> Culture for " + iso2 + ": " + culture.DisplayName
                        + " *** " + culture.NativeName
                        + " " + culture.TwoLetterISOLanguageName + " - " + culture.ThreeLetterISOLanguageName
                        + " - " + culture.DateTimeFormat.FullDateTimePattern);
                }
                //var culture = new CultureInfo("en-" + iso2);

            }
         %>

        <% 
                                  // Microsoft Geographical Location Values
                                  // https://msdn.microsoft.com/en-us/library/ms912389(WinEmbedded.11).aspx
           
        %>

        CurrentRegion.GeoId = <%= System.Globalization.RegionInfo.CurrentRegion.GeoId%>

        CurrentRegion.DisplayName = <%= System.Globalization.RegionInfo.CurrentRegion.DisplayName %> - <%= System.Globalization.RegionInfo.CurrentRegion.TwoLetterISORegionName %>
        CurrentUICulture = <%= System.Globalization.CultureInfo.CurrentUICulture.DisplayName %> - <%= System.Globalization.CultureInfo.CurrentUICulture.EnglishName %>
        CurrentCulture = <%= System.Globalization.CultureInfo.CurrentCulture.DisplayName %> - <%= System.Globalization.CultureInfo.CurrentCulture.EnglishName %>
        
        <%= System.Globalization.RegionInfo.CurrentRegion.Name %> - <%= System.Globalization.RegionInfo.CurrentRegion.NativeName %> - <%= System.Globalization.RegionInfo.CurrentRegion.ThreeLetterISORegionName %> - <%= System.Globalization.RegionInfo.CurrentRegion.ThreeLetterWindowsRegionName %>

        <%= System.Globalization.RegionInfo.CurrentRegion.ISOCurrencySymbol %> - <%= System.Globalization.RegionInfo.CurrentRegion.CurrencyNativeName%> - <%= System.Globalization.RegionInfo.CurrentRegion.CurrencySymbol%>
        
        <%= System.Globalization.CultureInfo.CurrentCulture.DateTimeFormat %>

    </pre>


    <div id="divCulture" style="width: 1150px; height: 250px; overflow-y: scroll; text-align: center">
        <%
            CultureInfo[] cinfo = CultureInfo.GetCultures(CultureTypes.AllCultures & ~CultureTypes.NeutralCultures);
            var list = new List<string>();
            foreach (System.Globalization.CultureInfo ci in System.Globalization.CultureInfo.GetCultures(System.Globalization.CultureTypes.AllCultures & ~CultureTypes.NeutralCultures))
            {
                string uiculture = "no one";
                try { uiculture = System.Globalization.CultureInfo.CreateSpecificCulture(ci.Name).Name; }
                catch { }
                list.Add("<tr><td>" + ci.Name + "</td><td>" + ci.EnglishName + "</td><td>" + uiculture + "</td><td>" + ci.DisplayName + "</td><td>" + ci.LCID + "</td></tr>");
            }

            list.Sort();
            Response.Write("<table border=\"1\">");
            Response.Write("<tr><th>Culture-Language-Country code</th><th>English Name</th><th>Ui Culture</th><th>Country Name</th><th>LCID</th></tr>");
            foreach (string str in list)
                Response.Write(str);
            Response.Write("</table>");

        %>
    </div>

    <hr align="left" width="30%" color="#04ACB5">
    <h2>Users</h2>
    <hr align="left" width="30%" color="#04ACB5">

    <div align="left">
        <table border="0" width="44%">
            <tr>
                <td width="34%"><font face="Verdana" size="2"> Environment.UserDomainName </font></td>
                <td width="4%"><font face="Verdana" size="2">:</font></td>
                <td width="66%"><font face="Verdana" size="2"><%= Environment.UserDomainName %></font></td>
            </tr>

            <tr>
                <td width="34%"><font face="Verdana" size="2"> Environment.UserName </font></td>
                <td width="4%"><font face="Verdana" size="2">:</font></td>
                <td width="66%"><font face="Verdana" size="2"><%= Environment.UserName %></font></td>
            </tr>

            <tr>
                <td width="34%"><font face="Verdana" size="2">WindowsIdentity.GetCurrent</font></td>
                <td width="4%"><font face="Verdana" size="2">:</font></td>
                <td width="66%"><font face="Verdana" size="2"><%= System.Security.Principal.WindowsIdentity.GetCurrent().Name %></font></td>
            </tr>

            <tr>
                <td width="34%"><font face="Verdana" size="2">HttpContext Identity</font></td>
                <td width="4%"><font face="Verdana" size="2">:</font></td>
                <td width="66%"><font face="Verdana" size="2"><%= HttpContext.Current.User.Identity.Name %></font></td>
            </tr>

            <tr>
                <td width="34%"><font face="Verdana" size="2"> Request["LOGON_USER"]</font></td>
                <td width="4%"><font face="Verdana" size="2">:</font></td>
                <td width="66%"><font face="Verdana" size="2"> <%= Request["LOGON_USER"]  %></font></td>
            </tr>

            <tr>
                <td width="34%"><font face="Verdana" size="2">LogonUserIdentity Name</font></td>
                <td width="4%"><font face="Verdana" size="2">:</font></td>
                <td width="66%"><font face="Verdana" size="2"><%= Request.LogonUserIdentity.Name %></font></td>
            </tr>

            <tr>
                <td width="34%"><font face="Verdana" size="2">LogonUserIdentity User</font></td>
                <td width="4%"><font face="Verdana" size="2">:</font></td>
                <td width="66%"><font face="Verdana" size="2"><%= Request.LogonUserIdentity.User.Value %></font></td>
            </tr>

            <tr>
                <td width="34%"><font face="Verdana" size="2">LogonUserIdentity AuthenticationType - ImpersonationLevel</font></td>
                <td width="4%"><font face="Verdana" size="2">:</font></td>
                <td width="66%"><font face="Verdana" size="2"><%= Request.LogonUserIdentity.AuthenticationType + " - " + Request.LogonUserIdentity.ImpersonationLevel %></font></td>
            </tr>

        </table>
    </div>



    <hr align="left" width="30%" color="#04ACB5">
    <h2>Paths</h2>
    <hr align="left" width="30%" color="#04ACB5">

    <pre>
  HttpRuntime.AppDomainAppVirtualPath = <%= HttpRuntime.AppDomainAppVirtualPath %>
  Request.ApplicationPath = <%= Request.ApplicationPath %>
  Request.FilePath = <%= Request.FilePath %>
  Root = <%= HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Authority) %>
  Server.MapPath = <%= HttpContext.Current.Server.MapPath(@"~") %>
  Page.ResolveUrl = <%= Page.ResolveUrl("~") %>
  VirtualPathUtility.ToAbsolute = <%= VirtualPathUtility.ToAbsolute(Request.FilePath) %>
  </pre>



    <hr align="left" width="30%" color="#04ACB5">
    <h2>Request</h2>
    <hr align="left" width="30%" color="#04ACB5">


    <pre>
  Response.Filter = <%= Request.Filter.ToString() %>
  Request.ApplicationPath = <%= Request.ApplicationPath %>
  Request.PhysicalApplicationPath = <%= Request.PhysicalApplicationPath %>
  Request.PhysicalPath = <%= Request.PhysicalPath %>
  Request.UrlReferrer = <%= Request.UrlReferrer %>
  Request.UserLanguages = <%= string.Join(",", (Request.UserLanguages ?? new string[0])) %>
  </pre>

    <hr align="left" width="30%" color="#04ACB5">
    <h2>Request</h2>
    <hr align="left" width="30%" color="#04ACB5">

    <pre>
    AbsoluteUri: <%= HttpContext.Current.Request.Url.AbsoluteUri %>
    Url: <%= HttpContext.Current.Request.Url.AbsoluteUri %>

        PathAndQuery <%= HttpContext.Current.Request.Url.PathAndQuery %> 
        Authority <%= HttpContext.Current.Request.Url.Authority %>
        AbsolutePath <%= HttpContext.Current.Request.Url.AbsolutePath %>
        Host <%= HttpContext.Current.Request.Url.Host %>
        OriginalString <%= HttpContext.Current.Request.Url.OriginalString %>
        Scheme <%= HttpContext.Current.Request.Url.Scheme %>
        Port <%= HttpContext.Current.Request.Url.Port %>

        RawUrl <%= HttpContext.Current.Request.RawUrl %> 
        IsSecureConnection <%= HttpContext.Current.Request.IsSecureConnection %>
        IsLocal <%= HttpContext.Current.Request.IsLocal %>

        HTTP_HOST <%= HttpContext.Current.Request.Url.AbsoluteUri %>
    </pre>


</div>

<div>
    <hr align="left" width="30%" color="#04ACB5">
    <h2>Environment Variables</h2>
    <hr align="left" width="30%" color="#04ACB5">

    <div id="GetEnvironmentVariables" style="width: 950px; height: 250px; overflow-y: scroll; text-align: center">
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
    </div>

</div>

<div>
    <hr align="left" width="30%" color="#04ACB5">
    <h2>Browser Information</h2>
    <hr align="left" width="30%" color="#04ACB5">


    <div align="left">
        <table border="0" width="44%">
            <tr>
                <td width="34%"><font face="Verdana" size="2">User Agent - HTTP_USER_AGENT </font></td>
                <td width="4%"><font face="Verdana" size="2">:</font></td>
                <td width="66%"><font face="Verdana" size="2"><%= Request.UserAgent %> - HTTP_USER_AGENT: <%=  Request.ServerVariables["HTTP_USER_AGENT"]  %></font></td>
            </tr>
            <tr>
                <td width="34%"><font face="Verdana" size="2">Accept-Encoding</font></td>
                <td width="4%"><font face="Verdana" size="2">:</font></td>
                <td width="66%"><font face="Verdana" size="2"><%= Request.Headers["Accept-Encoding"] %></font>- <strong>GZip Supported: <%= IsGZipSupported() %></strong> </td>
            </tr>
            <tr>
                <td width="34%"><font face="Verdana" size="2">ALL_HTTP</font></td>
                <td width="4%"><font face="Verdana" size="2">:</font></td>
                <td width="66%"><font face="Verdana" size="2"><%= Request.ServerVariables["ALL_HTTP"]  %></font></td>
            </tr>
            <tr>
                <td width="34%"><font face="Verdana" size="2">Browser Type</font></td>
                <td width="4%"><font face="Verdana" size="2">:</font></td>
                <td width="66%"><font face="Verdana" size="2"><%= Request.Browser.Browser %></font></td>
            </tr>
            <tr>
                <td width="34%"><font face="Verdana" size="2">Version</font></td>
                <td width="4%"><font face="Verdana" size="2">:</font></td>
                <td width="66%"><font face="Verdana" size="2"><%= Request.Browser.Version %></font></td>
            </tr>
            <tr>
                <td width="34%"><font face="Verdana" size="2">ActiveX Control</font></td>
                <td width="4%"><font face="Verdana" size="2">:</font></td>
                <td width="66%"><font face="Verdana" size="2"><%= Request.Browser.ActiveXControls %></font></td>
            </tr>
            <tr>
                <td width="34%"><font face="Verdana" size="2">Java Script</font></td>
                <td width="4%"><font face="Verdana" size="2">:</font></td>
                <td width="66%"><font face="Verdana" size="2"><%= Request.Browser.JavaScript %></font></td>
            </tr>
            <tr>
                <td width="34%"><font face="Verdana" size="2">Java Applet</font></td>
                <td width="4%"><font face="Verdana" size="2">:</font></td>
                <td width="66%"><font face="Verdana" size="2"><%= Request.Browser.JavaApplets %></font></td>
            </tr>
            <tr>
                <td width="34%"><font face="Verdana" size="2">VB Script</font></td>
                <td width="4%"><font face="Verdana" size="2">:</font></td>
                <td width="66%"><font face="Verdana" size="2"><%= Request.Browser.VBScript %></font></td>
            </tr>

            <tr>
                <td width="34%"><font face="Verdana" size="2">BrowserCapabilities</font></td>
                <td width="4%"><font face="Verdana" size="2">:</font></td>
                <td width="66%">
                    <div id="HttpBrowserCapabilities" style="width: 800px; height: 300px; overflow-y: scroll; text-align: center">
                        <asp:literal id="Literal1" runat="server" />
                    </div>

                </td>
            </tr>


            <tr>
                <td width="34%"><font face="Verdana" size="2">Headers</font></td>
                <td width="4%"><font face="Verdana" size="2">:</font></td>
                <td width="66%">
                    <div id="Headers" style="width: 800px; height: 300px; overflow-y: scroll; text-align: center">
                        <asp:literal id="Literal2" runat="server" />
                    </div>

                </td>
            </tr>


        </table>
    </div>


</div>


<div>
    <hr align="left" width="30%" color="#04ACB5">
    <h2>Certificados</h2>
    <hr align="left" width="30%" color="#04ACB5">
    <asp:repeater id="repeater1" runat="server"> 
            <HeaderTemplate> 
                <table> 
                    <tr> 
                        <td> 
                            Cert 
                        </td> 
                        <td> 
                            Public Key 
                        </td> 
                        <td> 
                            Private Key 
                        </td> 
                    </tr> 
            </HeaderTemplate> 
            <ItemTemplate> 
                <tr> 
                    <td> 
                    <%#((X509Certificate2)Container.DataItem).GetNameInfo(X509NameType.SimpleName, false) %> 
                    </td> 
                    <td> 
                    <%#Extensions.HasPublicKeyAccess((X509Certificate2)Container.DataItem) %> 
                    </td> 
                    <td> 
                    <%#Extensions.HasPrivateKeyAccess((X509Certificate2)Container.DataItem) %> 
                    </td> 
                </tr> 
            </ItemTemplate> 
            <FooterTemplate> 
                </table></FooterTemplate> 
        </asp:repeater>
</div>

<div>
    <h2>Trace</h2>

</div>
