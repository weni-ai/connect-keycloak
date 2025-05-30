<#macro loginLayout>
    <div class="greetings">
        ${msg("greetings")}
    </div>

    <section v-if="!!VTEXAppEmail" class="greetings-description">
        ${msg("accessPasswordSentToTheEmail")} {{ VTEXAppEmail }}.
    </section>

    <form id="kc-form-login" ref="kc-form-login" class="${properties.kcFormClass!}" action="${url.loginAction}"
        method="post">
        <unnnic-form-element
            label="<#if !realm.loginWithEmailAllowed>${msg('username')}<#elseif !realm.registrationEmailAsUsername>${msg('usernameOrEmail')}<#else>${msg('email')}</#if>">
            <unnnic-input :disabled="!!VTEXAppEmail" ref="loginUsername" v-model="usernameInput"
                placeholder="${msg('placeholderLoginName')}" name="username"
                :disabled="<#if usernameEditDisabled??>true<#else>false</#if>" autofocus @input="usernameInput = sanitizeHtml(usernameInput)"></unnnic-input>
        </unnnic-form-element>

        <unnnic-form-element label="${msg('password')}">
            <unnnic-input ref="password" v-model="passwordInput" native-type="password"
                placeholder="${msg('placeholderLoginPassword')}" name="password" allow-toggle-password @input="passwordInput = sanitizeHtml(passwordInput)"></unnnic-input>
        </unnnic-form-element>

        <div class="${properties.kcFormGroupClass!}">
            <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                <div class="${properties.kcFormButtonsWrapperClass!}">
                    <unnnic-button class="login-button" size="large" text="${msg('doLogIn')}"
                        type="primary" :disabled="!canLogin"></unnnic-button>
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