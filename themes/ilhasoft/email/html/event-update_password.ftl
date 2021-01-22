<html lang="en">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Lato:wght@400;700&display=swap" rel="stylesheet">
</head>

<body>
    <div>
        <div style="width: 670px; height: 500px">
          <header style="width: 670px; height: 52px; border-bottom: 1px solid #E2E6ED;"> 
            <img src="https://weni-media-sp.s3-sa-east-1.amazonaws.com/logo/Logo.png" alt="Weni-Logo" style="margin-left: 24px; margin-top: 10px;"/>
          </header>
          <section style="width: 574px; height: 280px; margin: 50px auto;">
            <div style="font-family: Lato; font-style: normal; font-weight: normal; font-size: 20px; line-height: 24px; color: #808080;"> Hi, <span style="font-family: Lato;color: #262626; font-size: 20px; font-weight: bold; font-style: normal;">${user.firstName}!</span></div>
            
            <div style="font-family: Lato; font-weight: bold; font-size: 20px; line-height: 28px; color: #262626; margin-top: 24px;">
              ${msg("eventUpdatePasswordBodyHtml",event.date, event.ipAddress)?no_esc}
            </div>
            
          </section>
          
          <footer style="width: 670px;height: 150px; border-top: 1px solid #E2E6ED; border-bottom: 8px solid #262626;margin: auto; text-align: center;">
 
            <img src="https://weni-media-sp.s3-sa-east-1.amazonaws.com/logo/Logo-small.png" alt="Weni-Logo" style="margin: 15px 0;"/>


            <div style="width: 450px; font-size: 12px;line-height: 20px;margin: auto;">
              <a style="cursor: pointer;margin-right: 10px;color: #9CACCC;">Visite o nosso site</a>
              <a style="cursor: pointer;margin-right: 10px;color: #9CACCC;">Facebook</a>
              <a style="cursor: pointer;margin-right: 10px;color: #9CACCC;">Instagram</a>
              <a style="cursor: pointer;margin-right: 10px;color: #9CACCC;">Twitter</a>
            </div>
          
          <div style="font-family: Lato;font-style: normal;font-weight: normal;font-size: 12px;line-height: 20px;color: #CCCCCC;text-align: center;margin-top:10px;">Weni © Brasil 2020 - Todos os direitos reservados</div>
        </footer>
            </div>
        </div>
</body>
</html>
