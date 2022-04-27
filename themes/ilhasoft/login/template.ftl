<#macro registrationLayout bodyClass="" displayInfo=false displayMessage=true displayHeader=true displaySocial=true>
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
        const togglePassword = (buttonId, inputId) => {
            console.log({ buttonId, inputId });
            const element = document.getElementById(inputId);
            const passwordIcon = document.getElementById(buttonId);

            if(!element || !passwordIcon) return;

            const type = element.type;
            element.type = type === 'password' ? 'text' : 'password';
            
            classes = passwordIcon.className.split(" ");
            classes[classes.length - 1] = type === 'password' ? 'icon-view-off-1' : 'icon-view-1-1';
            passwordIcon.className = classes.join(" ");
        };

        const disableButton = () => {
            const input = document.getElementById("required-input");
            const button = document.getElementById("required-input-button");

            if(!input || !button) return;

            button.disabled = input.value === null || input.value === undefined || input.value.trim().length === 0;
        };

        const closeModal = () => {
            const modal = document.getElementById("modal");
            console.log('remove');
            modal.remove()
        };
    </script>
    <script src="${url.resourcesPath}/vue/vue.min.js"></script>
</head>

<body class="${properties.kcBodyClass!}">
    <div class="${properties.kcLoginClass!}" id="app">
    <div class="${properties.kcFormCardClass!}">
    <#if displayHeader>
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
        <a href="${url.loginUrl}"><img class="brand-title" src="${url.resourcesPath}/img/login/brand.svg" ></a>
        <p class="title-md"> ${msg("headerTitleText")} </p>
        <p class="title-sm"> <@msg("headerTitleSubtext")?interpret /> </p>
        <p class="text-body-gt"> ${msg("brandsTitle")} </p>
        <div class="brand-container">
            <div class="brand">
                <img src="${url.resourcesPath}/img/login/brand-2.svg" >
            </div>

            <div class="brand">
                <img src="${url.resourcesPath}/img/login/brand-3.svg" >
            </div>

            <div class="brand">
                <img src="${url.resourcesPath}/img/login/brand-4.svg" >
            </div>

            <div class="brand">
                <img src="${url.resourcesPath}/img/login/brand-5.svg" >
            </div>
        </div>
            <#if displayMessage && message?has_content>
            <#if (message.summary == msg("emailSentMessage"))>
                <div id="modal" class="modal-background">
                    <div class="modal-container">
                        <div class="modal-content">
                            <div class="modal-button-container">
                                <span class="icon-close-1 icon-clickable" onclick="closeModal()"></span>
                            </div>
                            <div class="modal-center-icon">
                                <span class="icon-check-circle-1-1 icon-success"></span>
                            </div>
                        <div class="modal-title">${msg("emailSentTitle")}</div>
                        <div class="modal-text">${kcSanitize(message.summary)?no_esc}</div>
                    </div>
                    <div class="modal-message">${msg("emailSentSubitle")}</div>
                </div>

            <#elseif (message.summary == msg("verifyEmailMessage"))>
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
      </header>
    </#if>
    <#if displayHeader>
      <div id="kc-content">
    <#else>
    <div id="kc-content-headerless">
    </#if>
        <div id="kc-content-wrapper">
        <#if realm.password?? && social.providers?? && displaySocial>
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
    </div>
  </div>
    <script>
        $(document).ready(function(){
            $('#iconeTooltip').tooltip({container: 'body'});;
        });
    </script>
    <script type="text/javascript" async src="https://d335luupugsy2.cloudfront.net/js/loader-scripts/bc670956-964a-4451-9629-b0c74ae4b122-loader.js" ></script>

</body>
<footer></footer>
</html>
</#macro>
