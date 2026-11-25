<%@ Page Language="C#" Title="AspNetRuntimeDiagnostics" AutoEventWireup="True" ValidateRequest="false" %>

<%@ Import namespace="System.Collections.Generic"%>
<%@ Import namespace="System.Security.Principal"%>
<%@ Import namespace="System.Threading"%>
<%@ Import namespace="System.Globalization"%>
<%@ Import namespace="System.Diagnostics"%>
<%@ Import namespace="System.Reflection"%>


<%@ Register Src="AspNetRuntimeDiagnostics.ascx" TagName="Diagnostics" TagPrefix="uc" %>

<head id="Head1" runat="server" />

<script runat="server">

</script>

<uc:Diagnostics ID="Ctl_Diagnostics" runat="server" />