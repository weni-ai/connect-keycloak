<#macro loginLayout>
    <div class="greetings">
        <a href="${url.loginUrl}">
            <img class="brand-title" src="${url.resourcesPath}/img/login/Weni-Logo-Blue.svg">
        </a>

        ${msg("greetings")}
    </div>

    <section v-if="!!VTEXAppEmail" class="greetings-description">
        ${msg("accessPasswordSentToTheEmail")} {{ VTEXAppEmail }}.
    </section>

    <form id="kc-form-login" ref="kc-form-login" class="${properties.kcFormClass!}" action="${url.loginAction}"
        method="post">
        <unnnic-form-element
            label="<#if !realm.loginWithEmailAllowed>${msg('username')}<#elseif !realm.registrationEmailAsUsername>${msg('usernameOrEmail')}<#else>${msg('email')}</#if>">
            <unnnic-input :disabled="!!VTEXAppEmail" ref="loginUsername" v-model="usernameInput" icon-left="single-neutral-actions-1"
                placeholder="${msg('placeholderLoginName')}" name="username"
                :disabled="<#if usernameEditDisabled??>true<#else>false</#if>" autofocus @input="usernameInput = sanitizeHtml(usernameInput)"></unnnic-input>
        </unnnic-form-element>

        <unnnic-form-element label="${msg('password')}">
            <unnnic-input ref="password" v-model="passwordInput" native-type="password" icon-left="lock-2-1"
                placeholder="${msg('placeholderLoginPassword')}" name="password" allow-toggle-password></unnnic-input>
        </unnnic-form-element>

        <div class="${properties.kcFormGroupClass!}">
            <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                <div class="${properties.kcFormButtonsWrapperClass!} login-buttons">
                    <unnnic-button class="login-button" size="small" text="${msg('doLogIn')}"
                        type="primary"></unnnic-button>

                    <#if realm.password?? && social.providers??>
                        <#list social.providers as p>
                            <a id="zocial-${p.alias}" class="social-link" href="${p.loginUrl}">
                                <button type="button" class="social-button button-control" id="button-${p.alias}">
                                    <img src="${url.resourcesPath}/img/login/icon-${p.alias}.svg"
                                        class="icon-image icon-button-left">
                                </button>
                            </a>
                        </#list>
                    </#if>
                </div>
            </div>
        </div>

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
                <div class="forgot-password ${properties.kcInputMessageClass!}"><a tabindex="5"
                        href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a></div>
            </#if>
        </div>
    </form>
</#macro>