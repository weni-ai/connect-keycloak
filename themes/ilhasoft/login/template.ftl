<#macro registrationLayout bodyClass="" displayInfo=false displayMessage=true>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" class="${properties.kcHtmlClass!}">

<head>
    <meta charset="utf-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="robots" content="noindex, nofollow">

    <#if properties.meta?has_content>
        <#list properties.meta?split(' ') as meta>
            <meta name="${meta?split('==')[0]}" content="${meta?split('==')[1]}"/>
        </#list>
    </#if>
    <title><#nested "title"></title>
    <link rel="icon" href="${url.resourcesPath}/img/favicon.ico" />
    <#if properties.styles?has_content>
        <#list properties.styles?split(' ') as style>
            <link href="${url.resourcesPath}/${style}" rel="stylesheet" />
        </#list>
    </#if>
    <#if properties.scripts?has_content>
        <#list properties.scripts?split(' ') as script>
            <script src="${url.resourcesPath}/${script}" type="text/javascript"></script>
        </#list>
    </#if>
    <#if scripts??>
        <#list scripts as script>
            <script src="${script}" type="text/javascript"></script>
        </#list>
    </#if>
    <script>
        const togglePassword = () => {
            const element = document.getElementById("password");
            const passwordIcon = document.getElementById("password-icon");

            if(!element || !passwordIcon) return;

            const type = element.type;
            element.type = type === 'password' ? 'text' : 'password';
            
            classes = passwordIcon.className.split(" ");
            classes[classes.length - 1] = type === 'password' ? 'icon-view-off-1' : 'icon-view-1-1';
            passwordIcon.className = classes.join(" ");
        }
    </script>
</head>

<body class="${properties.kcBodyClass!}">
      <div class="${properties.kcLoginClass!}">
    <div class="${properties.kcFormCardClass!}">
      <header class="${properties.kcFormHeaderClass!}">
        <#if realm.internationalizationEnabled  && locale.supported?size gt 1>
            <div id="kc-locale">
                <div id="kc-locale-wrapper" class="${properties.kcLocaleWrapperClass!}">
                    <div class="kc-dropdown" id="kc-locale-dropdown">
                        <#--  <a href="#" id="kc-current-locale-link">${locale.current}</a>  -->
                        <a href="#" id="kc-current-locale-link">
                            ${locale.current}
                        </a>
                        <ul>
                            <#list locale.supported as l>
                                <#if l.label != locale.current>
                                    <li class="kc-dropdown-item"><a href="${l.url}">${l.label}</a></li>
                                </#if>
                            </#list>
                        </ul>
                    </div>
                </div>
            </div>
        </#if>
        <img class="brand" src="${url.resourcesPath}/img/login/brand.svg" >
        <p class="title-md"> ${msg("headerTitleText")} </p>
        <p class="text-md"> ${msg("headerTitleSubtext")} </p>
        <div class="brand-container">
            <img class="brand" src="${url.resourcesPath}/img/login/brand-2.svg" >
            <img class="brand" src="${url.resourcesPath}/img/login/brand-3.svg" >
            <img class="brand" src="${url.resourcesPath}/img/login/brand-4.svg" >
            <img class="brand" src="${url.resourcesPath}/img/login/brand-5.svg" >
        </div>
        <div class="home-back-link"> &larr; <a href="${properties.backUrl!}">${msg("backHome")}</span> </a>
      </header>
      <div id="kc-content">
        <div id="kc-content-wrapper">
          <#if displayMessage && message?has_content>

            <#if (message.summary == msg("verifyEmailMessage"))>
                <div class="alert alert-success">
                    <span class="${properties.kcFeedbackSuccessIcon!}"></span>
                    ${kcSanitize(message.summary)?no_esc}
                </div>
            <#else>
                <div class="alert alert-${message.type}">
                    <#if message.type = 'success'><span class="${properties.kcFeedbackSuccessIcon!}"></span></#if>
                    <#if message.type = 'warning'><span class="${properties.kcFeedbackWarningIcon!}"></span></#if>
                    <#if message.type = 'error'><span class="${properties.kcFeedbackErrorIcon!}"></span></#if>
                    <#if message.type = 'info'><span class="${properties.kcFeedbackInfoIcon!}"></span></#if>
                    <span class="kc-feedback-text">${kcSanitize(message.summary)?no_esc}</span>
                </div>
            </#if>
          <#else>
        </#if>
        <#if realm.password && social.providers??>
            <div class="buttons-group">
                <#list social.providers as p>
                    <a id="zocial-${p.alias}" class="social-link" href="${p.loginUrl}">
                        <button class="social-button button-control" id="button-${p.alias}">
                            <img src="${url.resourcesPath}/img/login/icon-${p.alias}.svg" class="icon-image icon-button-left" >
                            <span>${msg("loginWith")} ${p.displayName} </span>
                        </button></a>
                </#list>
            </div>
            <div id="separator-group">
                <div class="separator"></div>
                <span class="separator-text"> ${msg("separatorMessage")} </span>
                <div class="separator"></div>
            </div>
        </#if>
        <div id="kc-form" class="${properties.kcFormAreaClass!}">
            <div id="kc-form-wrapper" class="${properties.kcFormAreaWrapperClass!}">
                <#nested "form">
            </div>
        </div>
        <#if displayInfo>
              <div id="kc-info" class="${properties.kcSignUpClass!}">
                  <div id="kc-info-wrapper" class="${properties.kcInfoAreaWrapperClass!}">
                      <#nested "info">
                  </div>
              </div>
          </#if>
        </div>
      </div>
      <footer></footer>
    </div>
  </div>
    <script>
        $(document).ready(function(){
            $('#iconeTooltip').tooltip({container: 'body'});;
        });
    </script>
</body>
</html>
</#macro>
