<#macro registrationLayout bodyClass="" displayInfo=false displayMessage=true displayHeader=true displayRegisterScriptsAndStyles=false displayLoginFormScriptsAndStyles=false displaySocial=true>
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
    <script src="${url.resourcesPath}/vue/unnnic.umd.min.js"></script>
    <link href="${url.resourcesPath}/vue/unnnic.css" rel="stylesheet" />
</head>

<body class="${properties.kcBodyClass!}">
    <div class="${properties.kcLoginClass!}" id="app">
    <#if displayHeader>
      <header class="${properties.kcFormHeaderClass!}">
        <#if realm.internationalizationEnabled  && locale.supported?size gt 1>
            <div id="kc-locale">
                <div id="kc-locale-wrapper" class="${properties.kcLocaleWrapperClass!}">
                    <div class="kc-dropdown" id="kc-locale-dropdown">
                        <#--  <a href="#" id="kc-current-locale-link">${locale.current}</a>  -->
                        <div class="language-select">
                            <unnnic-language-select
                                :value="language"
                                @input="changeLanguage"
                                position="bottom"
                                :supported-languages="supportedLanguages"
                            ></unnnic-language-select>
                        </div>
                    </div>
                </div>
            </div>
        </#if>
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
    <div class="${properties.kcFormCardClass!}">
        <div class="left-side-content" style="grid-column: 1 / 7">
            <a href="${url.loginUrl}"><img class="brand-title" src="${url.resourcesPath}/img/login/brand.svg" ></a>

            <iframe src="https://flows.weni.ai/users/logout" style="display: none;"></iframe>
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
        </div>
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
  </div>
    <style>
        <#if displayLoginFormScriptsAndStyles>
            #rememberMe {
            display: none;
            }

            #rememberMe + label {
                background: url('${url.resourcesPath}/img/login/checkbox-default.svg') no-repeat;
                background-size: contain;
                height: 16px;
                width: 16px;
                display:inline-block;
                padding: 0;
                margin: 0 6px 0 0;
                cursor: pointer;
            }

            #rememberMe:checked + label {
                background: url('${url.resourcesPath}/img/login/checkbox-select.svg') no-repeat;
                background-size: contain;
                height: 16px;
                width: 16px;
                display: inline-block;
                padding: 0;
            }
        </#if>

        .login-pf-header {
            margin: 2rem 12.88%;
            align-self: normal;
            display: flex;
            align-items: flex-end;
            justify-content: flex-end;
            flex-direction: column;
        }

        .login-pf-header .language-select {
            width: 12.5rem;
        }
        
        .login-pf-header .language-select .unnnic-language-select {
            user-select: none;
            z-index: 1;
        }

        .card-pf {
            margin-top: 0;
        }
    </style>
    <script>
        const kc2UnnnicLanguages = {
            'pt-BR': 'pt-br',
            'en': 'en',
            'es': 'es',
        };

        const convert = (text) => {
            const data = {
                '&lt;': '<',
                '&gt;': '>',
                '&amp;': '&',
                '&quot;': '"',
                '&#39;': '\'',
            };

            return Object.keys(data).reduce((currentText, from) => {
                return currentText.replace(new RegExp(from, 'g'), data[from]);
            }, text);
        }

        new Vue({
            el: '#app',
            data: {
                <#if realm.internationalizationEnabled>
                    keycloakCurrentLanguage:
                        <#list locale.supported as l>
                            <#if l.label == locale.current>
                                "${l.languageTag}",
                            </#if>
                        </#list>
                    keycloakLanguages: {
                        <#list locale.supported as l>
                            "${l.languageTag}": convert("${l.url}"),
                        </#list>
                    },
                </#if>
                <#if displayRegisterScriptsAndStyles>
                    firstName: convert('${(register.formData.firstName!"")}'),
                    lastName: convert('${(register.formData.lastName!"")}'),
                    email: convert('${(register.formData.email!"")}'),
                    username: convert('${(register.formData.username!"")}'),
                    password: convert('${(register.formData.password!"")}'),
                    passwordConfirm: '',
                    seePassword: false,
                    seePasswordConfirm: false,
                </#if>
                <#if displayLoginFormScriptsAndStyles>
                    loginUsername: '',
                    loginPassword: '',
                </#if>
            },

            computed: {
                <#if displayRegisterScriptsAndStyles>
                    canRegister() {
                        return [
                            'firstName',
                            'lastName',
                            'email',
                            'username',
                            'password',
                            'passwordConfirm',
                        ].every(field => {
                            if (['firstName', 'lastName'].includes(field)) {
                                return this[field].length >= 3;
                            } if(['username'].includes(field)){
                                return this.$refs.username ? this[field].length : true;
                            } else {
                                return this[field].length;
                            }
                        });
                    },
                </#if>
                supportedLanguages() {
                    return Object.keys(this.keycloakLanguages)
                        .map((keycloakLanguage) => kc2UnnnicLanguages[keycloakLanguage])
                        .filter((language) => language);
                },

                language() {
                    return kc2UnnnicLanguages[this.keycloakCurrentLanguage];
                },
            },

            mounted() {
                <#if displayLoginFormScriptsAndStyles>
                    const username = this.$refs.username;
                    const password = this.$refs.password;
                    const submitButton = this.$refs['kc-login'];

                    const onInput = () => {
                        submitButton.disabled = !username.value || !password.value;
                    }

                    username.addEventListener('input', onInput);
                    password.addEventListener('input', onInput);

                    username.addEventListener('change', onInput);
                    password.addEventListener('change', onInput);

                    function emitConnectEvent(name, content) {
                        const data = {
                            pathname: window.location.pathname,
                            data: content,
                        }

                        if (window.top && window.top.postMessage) {
                            window.top.postMessage('connect:' + name + ':' + JSON.stringify(data), '*');
                        }
                    }

                    emitConnectEvent('requestlogout');
                </#if>
            },

            methods: {
                changeLanguage(language) {
                    Object.keys(this.keycloakLanguages)
                        .forEach((keycloakLanguage) => {
                            if (kc2UnnnicLanguages[keycloakLanguage] === language) {
                                const a = document.createElement('a');
                                a.setAttribute('href', this.keycloakLanguages[keycloakLanguage]);
                                document.body.appendChild(a);
                                a.click();
                            }
                        });
                },
            },
        });
    </script>

</body>
<footer></footer>
</html>
</#macro>
