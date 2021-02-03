<html lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link rel="preconnect" href="https://fonts.gstatic.com">
      <link href="https://fonts.googleapis.com/css2?family=Lato:wght@400;700&display=swap" rel="stylesheet">
    </head>
    
    <body>
        <div>
            <div style="width: 670px; min-height: 724px;">
            <header style="width: 670px; height: 52px; border-bottom: 1px solid #E2E6ED;"> 
                <img src="https://weni-media-sp.s3-sa-east-1.amazonaws.com/logo/Logo.png" alt="Weni-Logo" style="margin-left: 24px; margin-top: 10px;"/>
              </header>
              <section style="width: 574px; margin: 48px auto;">
                
                ${msg("passwordResetBodyText1Html")?no_esc}
                
                ${msg("passwordResetBodyText2Html", linkExpiration)?no_esc}
                
                <div style="cursor:pointer; margin: auto; width: 400px; text-align: center;background: #3B414D;color: #FFFFFF;font-size: 16px;
                font-family: Lato;margin-top:20px;border-radius: 4px; padding: 1px 0;">
                  ${msg("passwordResetBodyHtml",link)?no_esc}
                </div>
              </section>
              
              <footer style="width: 670px;height: 150px; border-top: 1px solid #E2E6ED; border-bottom: 8px solid #262626;margin: auto; text-align: center;">
 
                <img src="https://weni-media-sp.s3-sa-east-1.amazonaws.com/logo/Logo-small.png" alt="Weni-Logo" style="margin: 15px 0;"/>
  
                <div style="width: 450px; font-size: 12px;line-height: 20px;margin: auto;">
                  <a style="cursor: pointer;margin-right: 10px;color: #9CACCC;">${msg("emailAccessOurSite")?no_esc}</a>
                  <a style="cursor: pointer;margin-right: 10px;color: #9CACCC;">Facebook</a>
                  <a style="cursor: pointer;margin-right: 10px;color: #9CACCC;">Instagram</a>
                  <a style="cursor: pointer;margin-right: 10px;color: #9CACCC;">Twitter</a>
                </div>
              
              ${msg("emailCopyright")?no_esc}
              
              ${msg("passwordResetBodyText3Html")?no_esc}
            </footer>
                </div>
            </div>
    </body>
    </html>
    
    