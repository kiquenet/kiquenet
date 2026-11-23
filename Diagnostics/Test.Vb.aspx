<%@ Page Language="VB" %>

<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        lblVersion.Text = "Your server is running ASP.NET and the version is " & System.Environment.Version.ToString()
    End Sub
</script>

<html>
<head>
    <title>ASP.NET Version</title>
</head>
<body>
    <form id="form1" runat="server">
        <asp:Label ID="lblVersion" runat="server"></asp:Label>
    </form>
</body>
</html>