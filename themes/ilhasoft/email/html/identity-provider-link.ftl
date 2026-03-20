<html lang="en">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,400..600;1,14..32,400..600&display=swap" rel="stylesheet">
</head>

<body>
    <div>
        <div style="width: 670px; min-height: 724px;">
          <header style="width: 670px; height: 52px; border-bottom: 1px solid #E0E0E0;"> 
            <img src="https://weni-media-sp.s3-sa-east-1.amazonaws.com/logo/Logo.png" alt="Logo" style="margin-left: 24px; margin-top: 10px;"/>
          </header>
          <section style="width: 574px; min-height: 280px; margin: 50px auto;">
            <div style="font-family: 'Inter', sans-serif; font-style: normal; font-weight: normal; font-size: 20px; line-height: 24px; color: #707070;"> ${msg("emailVerificationWelcome",user.firstName)?no_esc}</div>
            
            <div style="font-family: 'Inter', sans-serif; font-weight: bold; font-size: 20px; line-height: 28px; color: #1F1F1F; margin-top: 24px;">
              ${msg("identityProviderLinkBodyHtml", identityProviderAlias, realmName, identityProviderContext.username, link, linkExpiration)?no_esc}
            </div>
            
          </section>
          
          <footer style="width: 670px;height: 150px; border-top: 1px solid #E0E0E0; border-bottom: 8px solid #1F1F1F;margin: auto; text-align: center;">
 
            <img src="https://weni-media-sp.s3-sa-east-1.amazonaws.com/logo/Logo-small.png" alt="Logo" style="margin: 15px 0;"/>


            <div style="width: 450px; font-size: 12px;line-height: 20px;margin: auto;">
              <a style="cursor: pointer;margin-right: 10px;color: #ADADAD;">${msg("emailAccessOurSite")?no_esc}</a>
              <a style="cursor: pointer;margin-right: 10px;color: #ADADAD;">Facebook</a>
              <a style="cursor: pointer;margin-right: 10px;color: #ADADAD;">Instagram</a>
              <a style="cursor: pointer;margin-right: 10px;color: #ADADAD;">Twitter</a>
            </div>
          
          ${msg("emailCopyright")?no_esc}
        </footer>
            </div>
        </div>
</body>
</html>
