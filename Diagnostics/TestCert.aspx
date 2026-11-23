<%@ Page Title="Diagnostico Certificados" Language="C#" AutoEventWireup="true"  %>

<%@ Assembly Name="System.Security, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a" %> 

<%@ Import Namespace="System.Security.Cryptography.X509Certificates"  %> 
<%@ Import Namespace="System.Security.Cryptography.Pkcs" %>
<%@ Import Namespace="System.Security.Principal" %>
<%@ Import Namespace="System.Security" %>
<%@ Import Namespace="System.Security.Permissions" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="System.Threading" %>



<html>
<head id="Head1" runat="server">

</head>
<script runat="server">

void Page_Load()
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
	
		if (HttpContext.Current.User.Identity.IsAuthenticated)
		{
			if (HttpContext.Current.User.Identity.GetType() == typeof(FormsIdentity))
			{
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
		}
	
            

}

         
 public X509Certificate2Collection Certificates;
 
        void btn_click(Object source, EventArgs e)
        {
/*
MyClass mycls = new MyClass() ;
                int x = Int32.Parse(a.Text) ;
                int y = Int32.Parse(b.Text);
                
                Message.Text = mycls.Add( x, y).ToString() ;
                */
                Message.Text = "Pruebas";
                
                
                 // Local Computer\Personal 
            var store = new X509Store(StoreLocation.LocalMachine);
            // create and open store for read-only access 
            //store.Open(OpenFlags.ReadOnly);
            store.Open(OpenFlags.ReadOnly | OpenFlags.OpenExistingOnly);
            Certificates = store.Certificates;
            repeater1.DataSource = Certificates;
            repeater1.DataBind();
            
            var nombreCertificado = "ENTIDAD REALE SEGUROS GENERALES SA - CIF A78520293 - NOMBRE LOZANO YEBRA JESUS - NIF 02697501S"; //"ENTIDAD REALE VIDA Y PENSIONES SA - CIF A85877066 - NOMBRE LOZANO YEBRA JESUS - NIF 02697501S";
            
            //winhttpcertcfg.exe -l -c LOCAL_MACHINE\My -s "ENTIDAD REALE VIDA Y PENSIONES SA - CIF A85877066 - NOMBRE LOZANO YEBRA JESUS - NIF 02697501S" 
            
          

            var certificadoReale = GetCertificateByNameInLocalMachine(nombreCertificado);
            if (certificadoReale != null)
            {
                Message.Text += "Certificado " + nombreCertificado + " encontrado en " + StoreLocation.LocalMachine;
                FirmarConCertificado(nombreCertificado, certificadoReale);
            }
            else
            {
                
                //throw new ConfigurationErrorsException("El certificado " + nombreCertificado + " no esta instalado en la máquina");
                
                Message.Text += "El certificado " + nombreCertificado + " no esta instalado en la máquina";
            }
            
             Message.Text += "<hr />";
            
              var nombreCertificadoVida = "ENTIDAD REALE VIDA Y PENSIONES SA - CIF A85877066 - NOMBRE LOZANO YEBRA JESUS - NIF 02697501S";
            var certificadoVida = GetCertificateByNameInLocalMachine(nombreCertificadoVida);
            if (certificadoVida != null)
            {
                Message.Text += "Certificado " + nombreCertificadoVida + " encontrado en " + StoreLocation.LocalMachine;
                FirmarConCertificado(nombreCertificadoVida, certificadoVida);
            }
            else
            {
                
                //throw new ConfigurationErrorsException("El certificado " + nombreCertificadoVida + " no esta instalado en la máquina");
                
                Message.Text += "El certificado " + nombreCertificadoVida + " no esta instalado en la máquina";
            }
        }
</script>

<body>

<h1>Pruebas Certificados</h1>

        
<form id="Form1" Action="TestCert.aspx" runat="server">

        <p>
        <asp:label id="lbInfo" runat="server" style="background-color: White; color: Blue; font-weight: bold;" />
        <br /><br /><br />
        </p>
        
        
        <asp:TextBox id="a" runat="server" Visible="false" />
        <asp:TextBox id="b" runat="server" Visible="false" />
        <asp:button id=btn OnClick="btn_click" Text="Pruebas para certificados" runat="server" />
        
        <p>
        <br /><br /><br />
        <asp:label id="Message" runat="server" style="background-color: Yellow; color: Red; font-weight: bold;" />
        <br /><br /><br />
        </p>
        
        
            <div> 
        <asp:Repeater ID="repeater1" runat="server"> 
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
                    <%#((X509Certificate2)Container.DataItem).HasPublicKeyAccess() %> 
                    </td> 
                    <td> 
                    <%#((X509Certificate2)Container.DataItem).HasPrivateKeyAccess() %> 
                    </td> 
                </tr> 
            </ItemTemplate> 
            <FooterTemplate> 
                </table></FooterTemplate> 
        </asp:Repeater> 
    </div> 

</form>


<script runat="server">

public void FirmarConCertificado(string nombreCertificado, X509Certificate2 certificate)
{
    try
    {
 var mensaje = "Datos de prueba";
                System.Text.Encoding enc = System.Text.Encoding.Default;
                byte[] data = enc.GetBytes(mensaje);

                var contentInfo = new System.Security.Cryptography.Pkcs.ContentInfo(data);
                var signedCms = new System.Security.Cryptography.Pkcs.SignedCms(contentInfo, true);

                var cmsSigner = new System.Security.Cryptography.Pkcs.CmsSigner(certificate);

                //  Sign the CMS/PKCS #7 message
                signedCms.ComputeSignature(cmsSigner);

                //  Encode the CMS/PKCS #7 message
               var ret = Convert.ToBase64String(signedCms.Encode());
               
Message.Text += "<br/><br/>****************************<br/>";                
 Message.Text += "Firmado con Certificado " + nombreCertificado + " que se ha encontrado en " + StoreLocation.LocalMachine;
 Message.Text += "<br/>****************************<br/><br/>";
 
 }
 catch (Exception ex)
 {
 Message.Text += "<br /><br />Error al firmar con certificado: " + ex.ToString();
 Message.Text += "<br /><br />InnerException: " + ex.InnerException; 
 }
 
}


public X509Certificate2 GetCertificateByNameInLocalMachine(string nombreCertificado)
{
            var store = new X509Store(StoreName.My, StoreLocation.LocalMachine);
            store.Open(OpenFlags.ReadOnly | OpenFlags.OpenExistingOnly);

            X509Certificate2Collection col = store.Certificates.Find(X509FindType.FindBySubjectName, nombreCertificado, false);

            if (col.Count > 0)
            {
                X509Certificate2 certificate = col[0];
                store.Close();
                return certificate;
            }
            
            store.Close();
            return null;
            
}
 
public X509Certificate2 GetCertificateBySubject(string subject, StoreName storeName, StoreLocation storeLocation)
{
    X509Store xstore = new X509Store(storeName, storeLocation);
    xstore.Open(OpenFlags.ReadOnly | OpenFlags.OpenExistingOnly);
 
    X509Certificate2 cert = null;
    foreach (X509Certificate2 cert2 in xstore.Certificates)
    {
        /*string sub = wwUtils.ExtractString(cert2.Subject, "CN=", ",", true, true);
 
        if (subject == sub)
        {
            cert = cert2;
            break;
        }
        */
    }
    return cert;
}

 
public X509Certificate2 GetCertificateBySubject(string subject)
{
    return this.GetCertificateBySubject(subject, StoreName.My, StoreLocation.CurrentUser);
}
 
                
public X509Certificate2 GetCertificateFromFile(string fileName)
{
    X509Certificate cert = X509Certificate.CreateFromCertFile(fileName);
    return new X509Certificate2(cert);
}


</script>

</body>
</html>


