<#macro registrationLayout bodyClass="" displayInfo=true displayMessage=true displayHeader=true displayRegisterScriptsAndStyles=false displayLoginFormScriptsAndStyles=false displaySocial=true>
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
        const closeModal = (message) => {
            const modal = document.getElementById("modal");
            modal.remove()

            if (message === 'verifyEmail') {
                const restartLogin = "${url.loginRestartFlowUrl}";

                window.location.href = restartLogin;
            }
        };
    </script>
    <script>
        // Shim for process.env which some npm packages expect
        window.process = window.process || { env: { NODE_ENV: 'production' } };
    </script>
    <script src="${url.resourcesPath}/vue/vue.min.js"></script>
    <#--  <script src="https://cdn.jsdelivr.net/npm/vue@2/dist/vue.js"></script>  -->
    <script>
        // Vue 2 compatibility shim - add Vue.use as no-op to prevent Unnnic auto-install errors
        // Unnnic will be properly registered later using app.use()
        window.Vue.use = function(plugin, options) {
            console.log('Vue.use shim: captured plugin for later registration');
        };
    </script>
    <script src="${url.resourcesPath}/vue/unnnic.umd.min.js"></script>
    <script src="${url.resourcesPath}/vue/modal-dialog.js"></script>
    <script src="${url.resourcesPath}/js/sanatize-1.js"></script>
    <link href="${url.resourcesPath}/vue/unnnic.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200&display=swap" rel="stylesheet" />
</head>

<body class="${properties.kcBodyClass!}" style="display: none;">
    <div class="${properties.kcLoginClass!}" id="app">
    <div class="${properties.kcFormCardClass!}">
        <div class="left-side-content">
            <a href="${url.loginUrl}" class="brand-logo-link">
                <img src="${url.resourcesPath}/img/login/brand.svg" alt="Logo" class="brand-logo" />
            </a>
            <img src="${url.resourcesPath}/img/login/background-left-content.svg" alt="Background Left Content" />
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
            <div id="kc-content-wrapper" class="custom-header-content">

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
                    <modal-dialog
                        :show="emailSentModal"
                        @close="closeEmailSentModal"
                        text="${msg('emailSentTitle')}"
                    >
                        <div slot="message" style="text-align: center;">
                            ${kcSanitize(message.summary)?no_esc}
                        </div>
                    </modal-dialog>
                <#else>
                    <#-- Alert moved to kc-form-wrapper for correct positioning -->
                </#if>
            </#if>

            <div id="kc-form" class="${properties.kcFormAreaClass!}">
                <div id="kc-form-wrapper" class="${properties.kcFormAreaWrapperClass!}">
                    <#-- Alert positioned here to appear after greetings with CSS order -->
                    <#if displayMessage && message?has_content>
                        <#if (message.summary != msg("loginTimeout")) && (message.summary != msg("verifyEmailMessage")) && (message.summary != msg("emailSentMessage"))>
                            <unnnic-disclaimer
                                class="login-disclaimer"
                                type="<#if message.type = 'error'>error<#elseif message.type = 'warning'>attention<#elseif message.type = 'success'>success<#else>informational</#if>"
                                description="${kcSanitize(message.summary)}"
                            ></unnnic-disclaimer>
                        </#if>
                    </#if>
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
        
        let VTEXAppEmail;

        const redirectURI = new URLSearchParams(document.location.search).get('redirect_uri');

        if (redirectURI) {
            const vtexApp = new URL(redirectURI).searchParams.get('vtex_app');
            VTEXAppEmail = new URLSearchParams(vtexApp || '').get('email');
        }

        const app = Vue.createApp({
            data() {
                return {
                    registerPasswordFocused: false,
                    registerPasswordConfirmFocused: false,
                    emailSentModal: true,
                    VTEXAppEmail,
                    usernameInput: VTEXAppEmail || '${((login.username)!'')}',
                    passwordInput: '',
                    logoutSessions: true,
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
                        passwordRules: {
                            lowercase: false,
                            uppercase: false,
                            number: false,
                            specialChar: false,
                            minLength: false,
                            passwordEquals: false,
                        },
                    </#if>
                    <#if displayLoginFormScriptsAndStyles>
                        loginUsername: '',
                        loginPassword: '',
                        loginPasswordVisible: false,
                        rememberMe: <#if login?? && login.rememberMe??>true<#else>false</#if>,
                    </#if>
                };
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
                <#if displayLoginFormScriptsAndStyles>
                    canLogin() {
                        return this.isEmailValid(this.usernameInput) && 
                               this.passwordInput && this.passwordInput.trim().length > 0;
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

            watch: {
                <#if displayRegisterScriptsAndStyles>
                password(newPassword) {
                    this.passwordRules.lowercase = /[a-z]/.test(newPassword);
                    this.passwordRules.uppercase = /[A-Z]/.test(newPassword);
                    this.passwordRules.number = /[0-9]/.test(newPassword);
                    this.passwordRules.specialChar = /[^a-zA-Z0-9]/.test(newPassword);
                    this.passwordRules.minLength = newPassword.length >= 8;
                    this.passwordRules.passwordEquals = newPassword === this.passwordConfirm && this.passwordConfirm.length > 0;
                },
                passwordConfirm(newPasswordConfirm) {
                    this.passwordRules.passwordEquals = this.password === newPasswordConfirm && newPasswordConfirm.length > 0;
                }
                </#if>
            },

            mounted() {
                if(!localStorage.getItem('haveLanguagePreference')) {
                    this.changeLanguage('en')
                }
                
                <#if displayRegisterScriptsAndStyles>
                if (this.password) {
                    this.passwordRules.lowercase = /[a-z]/.test(this.password);
                    this.passwordRules.uppercase = /[A-Z]/.test(this.password);
                    this.passwordRules.number = /[0-9]/.test(this.password);
                    this.passwordRules.specialChar = /[^a-zA-Z0-9]/.test(this.password);
                    this.passwordRules.minLength = this.password.length >= 8;
                    this.passwordRules.passwordEquals = this.password === this.passwordConfirm && this.passwordConfirm.length > 0;
                }
                </#if>
                
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
                document.body.style.display = 'flex'
            },

            methods: {
                // Expose sanitizeHtml to Vue template (loaded from sanatize-1.js)
                sanitizeHtml(input) {
                    return window.sanitizeHtml ? window.sanitizeHtml(input) : input;
                },

                // Navigate to a URL (window.location is not accessible in Vue 3 templates)
                navigateTo(url) {
                    window.location.href = url;
                },

                isEmailValid(email) {
                    if (!email) return false;
                    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                    return emailRegex.test(email);
                },

                changeLanguage(language) {
                    Object.keys(this.keycloakLanguages)
                        .forEach((keycloakLanguage) => {
                            if (kc2UnnnicLanguages[keycloakLanguage] === language) {
                                const a = document.createElement('a');
                                a.setAttribute('href', this.keycloakLanguages[keycloakLanguage]);
                                document.body.appendChild(a);
                                a.click();
                                localStorage.setItem('haveLanguagePreference', true)
                            }
                        });
                },

                closeEmailSentModal() {
                    this.emailSentModal = false;
                },

                toggleLoginPasswordVisibility() {
                    this.loginPasswordVisible = !this.loginPasswordVisible;
                },
            },
        });

        // Register Unnnic components with Vue 3 app
        if (window.Unnnic) {
            // Register the specific Unnnic components used in this theme
            const componentsToRegister = {
                'unnnic-language-select': window.Unnnic.unnniclanguageSelect,
                'unnnic-icon': window.Unnnic.unnnicIcon,
                'unnnic-form-element': window.Unnnic.unnnicFormElement,
                'unnnic-input': window.Unnnic.unnnicInput,
                'unnnic-button': window.Unnnic.unnnicButton,
                'unnnic-checkbox': window.Unnnic.unnnicCheckbox,
                'unnnic-alert': window.Unnnic.unnnicAlert,
                'unnnic-disclaimer': window.Unnnic.unnnicDisclaimer,
            };
            
            Object.entries(componentsToRegister).forEach(([name, component]) => {
                if (component) {
                    app.component(name, component);
                } else {
                    console.warn('Unnnic component not found:', name);
                }
            });
        }
        
        // Register modal-dialog component
        app.component('modal-dialog', ModalDialog);
        
        // Mount the app
        app.mount('#app');
    </script>

    <script>
        const realm = "${realm.name}";

        const flowsLogoutURLByRealms = {
            "weni": "https://flows.weni.ai/users/logout",
            "weni-staging": "https://flows.stg.cloud.weni.ai/users/logout",
            "weni-develop": "https://flows.dev.cloud.weni.ai/users/logout",
        }

        const flowsLogoutURL = flowsLogoutURLByRealms[realm];

        if (flowsLogoutURL) {
            const iframe = document.createElement('iframe');
            iframe.setAttribute('src', flowsLogoutURL);
            iframe.setAttribute('style', 'display: none;');
            document.body.appendChild(iframe);
        }
    </script>
</body>
<footer></footer>
</html>
</#macro>
