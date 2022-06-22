<#macro loginLayout>
    <form id="kc-form-login" class="${properties.kcFormClass!}" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post">
                <div class="${properties.kcFormGroupClass!}">
                    <div class="${properties.kcLabelWrapperClass!}">
                        <label for="username" class="${properties.kcLabelClass!}"><#if !realm.loginWithEmailAllowed>${msg("username")}<#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}<#else>${msg("email")}</#if></label>
                    </div>

                    <div class="${properties.kcInputWrapperClass!} ${properties.kcInputControlClass!}">
                        <label for="username">
                            <span class="icon icon-input icon-left icon-single-neutral-actions-1"></span>
                        </label>

                        <#if usernameEditDisabled??>
                            <input tabindex="1" id="username" class="${properties.kcInputClass!} has-icon-left" placeholder="${msg("placeholderLoginName")}" name="username" value="${(login.username!'')}" type="text" disabled />
                        <#else>
                            <input tabindex="1" id="username" class="${properties.kcInputClass!} has-icon-left" placeholder="${msg("placeholderLoginName")}" name="username" value="${(login.username!'')}" type="text" autofocus autocomplete="off" />
                        </#if>
                    </div>
                </div>

                <div class="${properties.kcFormGroupClass!}">
                    <div class="${properties.kcLabelWrapperClass!}">
                        <label for="password" class="${properties.kcLabelClass!}">${msg("password")}</label>
                    </div>

                    <div class="${properties.kcInputWrapperClass!} ${properties.kcInputControlClass!}">
                        <input tabindex="2" id="password" class="${properties.kcInputClass!} has-icon-left has-icon-right" placeholder="${msg("placeholderLoginPassword")}" name="password" type="password" autocomplete="off" />

                        <label for="password" class="m-0">
                            <span class="icon icon-input icon-left icon-lock-2-1"></span>
                        </label>

                        <span id="password-icon" onclick="togglePassword('password-icon', 'password')" class="icon icon-clickable icon-input icon-right icon-view-1-1"></span>
                        </div>
                    </div>
                </div>

                <div class="${properties.kcFormGroupClass!}">
                    <div id="kc-form-options" class="${properties.kcFormOptionsClass!}">
                        <#if realm.rememberMe && !usernameEditDisabled??>
                            <div class="input-message remember-me">
                                <#if login.rememberMe??>
                                    <input id="rememberMe" tabindex="3" name="rememberMe" type="checkbox" tabindex="3" checked>
                                <#else>
                                    <input id="rememberMe" tabindex="3" name="rememberMe" type="checkbox" tabindex="3">
                                </#if>

                                <label for="rememberMe"></label>
                                <label for="rememberMe">${msg("rememberMe")}</label>
                            </div>
                        </#if>

                        <#if realm.resetPasswordAllowed>
                            <div class="forgot-password ${properties.kcInputMessageClass!}"><a tabindex="5" href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a></div>
                        </#if>
                    </div>

                    <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                        <div class="${properties.kcFormButtonsWrapperClass!}">
                            <button type="submit" class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}" name="login" id="kc-login" type="submit">
                                ${msg("doLogIn")}
                            </button>
                        </div>
                     </div>
                </div>

                <script>
                
                    const username = document.querySelector('#username');
                    const password = document.querySelector('#password');
                    const submitButton = document.querySelector('#kc-login');

                    const onInput = () => {
                        submitButton.disabled = !username.value || !password.value;
                    }

                    username.addEventListener('input', onInput);
                    password.addEventListener('input', onInput);

                    username.addEventListener('change', onInput);
                    password.addEventListener('change', onInput);

                    document.querySelector('#kc-form-login').addEventListener("load", onInput);
                
                </script>

                <script>
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
                </script>
            </form>
</#macro>