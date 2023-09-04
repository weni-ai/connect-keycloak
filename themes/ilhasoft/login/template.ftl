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

        const closeModal = (message) => {
            const modal = document.getElementById("modal");
            modal.remove()

            if (message === 'verifyEmail') {
                const restartLogin = "${url.loginRestartFlowUrl}";

                location.href = restartLogin;
            }
        };
    </script>
    <script src="${url.resourcesPath}/vue/vue.min.js"></script>
    <#--  <script src="https://cdn.jsdelivr.net/npm/vue@2/dist/vue.js"></script>  -->
    <script src="${url.resourcesPath}/vue/unnnic.umd.min.js"></script>
    <link href="${url.resourcesPath}/vue/unnnic.css" rel="stylesheet" />
</head>

<body class="${properties.kcBodyClass!}">
    <div class="${properties.kcLoginClass!}" id="app">
    <div class="${properties.kcFormCardClass!}">
        <div class="left-side-content">
        <div class="content">
            <a href="${url.loginUrl}"><img class="brand-title" src="${url.resourcesPath}/img/login/Logo-Weni.svg"></a>

            <iframe src="https://flows.weni.ai/users/logout" style="display: none;"></iframe>
            
            <div>
            <div style="position: relative;">
            <img src="${url.resourcesPath}/img/login/icon-weni-1.svg" class="icon-weni-background">
            <img src="${url.resourcesPath}/img/login/screen2.png" class="icon-screen-background">

            <div class="benefits">
                <p class="title">${msg("headerTitleText")}</p>

                <div class="benefits-list">
                    <div class="benefit">
                        <unnnic-icon icon="check-double" size="sm"></unnnic-icon>
                        ${msg("benefits1")}
                    </div>
                    <div class="benefit">
                        <unnnic-icon icon="check-double" size="sm"></unnnic-icon>
                        ${msg("benefits2")}
                    </div>
                    <div class="benefit">
                        <unnnic-icon icon="check-double" size="sm"></unnnic-icon>
                        ${msg("benefits3")}
                    </div>
                    <div class="benefit">
                        <unnnic-icon icon="check-double" size="sm"></unnnic-icon>
                        ${msg("benefits4")}
                    </div>
                    <div class="benefit">
                        <unnnic-icon icon="check-double" size="sm"></unnnic-icon>
                        ${msg("benefits5")}
                    </div>
                </div>
            </div>
            </div>
            <div class="recommended-by">
                <p class="title">${msg("brandsTitle")}</p>
                <div class="brand-container">
                    <div class="brand">
                        <img src="${url.resourcesPath}/img/login/Stone.svg" >
                    </div>

                    <div class="brand">
                        <img src="${url.resourcesPath}/img/login/Unicef.svg" >
                    </div>

                    <div class="brand">
                        <img src="${url.resourcesPath}/img/login/Governo-do-Ceara.svg" >
                    </div>

                    <div class="brand">
                        <img src="${url.resourcesPath}/img/login/Bild.svg" >
                    </div>
                </div>
            </div>
            </div>
            <div class="brand-title-spacing"></div>
        </div>
        </div>
        <#if displayHeader>
        <div id="kc-content">
        <div class="content">
            <#if realm.internationalizationEnabled  && locale.supported?size gt 1>
                <#--  <a href="#" id="kc-current-locale-link">${locale.current}</a>  -->
                <div class="language-select top">
                    <unnnic-language-select
                        :value="language"
                        @input="changeLanguage"
                        position="bottom"
                        :supported-languages="supportedLanguages"
                    ></unnnic-language-select>
                </div>
            </#if>
        <#else>
        <div id="kc-content-headerless">
        </#if>
            <div id="kc-content-wrapper">

            <#--  <div id="modal" class="modal-background">
                <div class="modal-container">
                    <div class="modal-content">
                        <div class="modal-button-container">
                            <span class="icon-close-1 icon-clickable" onclick="closeModal()"></span>
                        </div>
                        <div class="modal-center-icon">
                            <span class="icon-check-circle-1-1 icon-success"></span>
                        </div>
                    <div class="modal-title">${msg("emailSentTitle")}</div>
                    <div class="modal-text">messa</div>
                </div>
                <div class="modal-message">${msg("emailSentSubitle")}</div>
            </div>  -->

            <#if displayMessage && message?has_content>
                <#if (message.summary == msg("loginTimeout")) || (message.summary == msg("verifyEmailMessage"))>
                <#elseif (message.summary == msg("emailSentMessage"))>
                    <unnnic-modal
                        v-if="emailSentModal"
                        @close="closeEmailSentModal"
                        text="${msg('emailSentTitle')}"
                        scheme="feedback-green"
                        modal-icon="check-circle-1-1"
                    >
                        <div slot="message" style="text-align: center;">
                            ${kcSanitize(message.summary)?no_esc}
                        </div>
                    </unnnic-modal>
                <#else>
                    <div class="alert alert-${message.type}">
                        <#if message.type = 'success'></#if>
                        <#if message.type = 'warning'></#if>
                        <#if message.type = 'error'><unnnic-icon icon="alert-circle-1-1" scheme="feedback-red"></unnnic-icon></#if>
                        <#if message.type = 'info'></#if>
                        <span class="kc-feedback-text">${kcSanitize(message.summary)?no_esc}</span>
                    </div>
                </#if>
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
                <#if realm.internationalizationEnabled  && locale.supported?size gt 1>
                    <#--  <a href="#" id="kc-current-locale-link">${locale.current}</a>  -->
                    <div class="footer">
                        <div class="language-select bottom">
                            <unnnic-language-select
                                :value="language"
                                @input="changeLanguage"
                                position="top"
                                :supported-languages="supportedLanguages"
                            ></unnnic-language-select>
                        </div>
                    </div>
                </#if>
            </div>
            <div class="language-select-counterpoint"></div>
        </div>
        <#if displayHeader>
        </div>
        </#if>
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
                registerPasswordFocused: false,
                registerPasswordConfirmFocused: false,
                emailSentModal: true,
                usernameInput: '${(login.username!'')}',
                passwordInput: '',
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
                if (this.$refs.registerPassword) {
                    const registerPasswordInput = this.$refs.registerPassword.$el.querySelector('input');

                    registerPasswordInput.addEventListener('focus', () => {
                        this.registerPasswordFocused = true;
                    });

                    registerPasswordInput.addEventListener('blur', () => {
                        this.registerPasswordFocused = false;
                    });
                }


                if (this.$refs.registerPasswordConfirm) {
                    const registerPasswordConfirmInput = this.$refs.registerPasswordConfirm.$el.querySelector('input');

                    registerPasswordConfirmInput.addEventListener('focus', () => {
                        this.registerPasswordConfirmFocused = true;
                    });

                    registerPasswordConfirmInput.addEventListener('blur', () => {
                        this.registerPasswordConfirmFocused = false;
                    });
                }

                if (this.$refs.loginUsername) {
                    this.$refs.loginUsername.$el.querySelector('input').addEventListener('animationstart', (event) => {
                        if (event.animationName === 'onAutoFillStart') {
                            setTimeout(() => {
                            console.log(this.$refs.loginUsername.$el.querySelector('input').value);

                            });
                        }
                        /*switch (e.animationName) {
                            case defaultStyles.onAutoFillStart:
                            return this.onAutoFillStart()

                            case defaultStyles.onAutoFillCancel:
                            return this.onAutoFillCancel()
                        }*/
                    })
                }

                <#if displayLoginFormScriptsAndStyles>
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

                closeEmailSentModal() {
                    this.emailSentModal = false;
                },
            },
        });
    </script>

    <script src="https://cdn.ingest-lr.com/LogRocket.min.js" crossorigin="anonymous"></script>

    <script>
        const realm = "${realm.name}";

        const logRocketIdByRealms = {
            "weni": "weni/production-rxhyp",
            "weni-staging": "weni/staging-15tbe",
            "weni-develop": "weni/develop",
        }

        const logRocketId = logRocketIdByRealms[realm];

        if (logRocketId && window.LogRocket) {
            window.LogRocket.init(logRocketId);
        }
    </script>
</body>
<footer></footer>
</html>
</#macro>
