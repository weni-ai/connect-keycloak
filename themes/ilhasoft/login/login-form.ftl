<#macro loginLayout>
    <h2 class="login-title">${msg("loginFormTitle")}</h2>
    <form id="kc-form-login" ref="kc-form-login" class="${properties.kcFormClass!}" action="${url.loginAction}"
        method="post">
        <unnnic-form-element
            label="<#if !realm.loginWithEmailAllowed>${msg('username')}<#elseif !realm.registrationEmailAsUsername>${msg('usernameOrEmail')}<#else>${msg('email')}</#if>">
            <unnnic-input :disabled="!!VTEXAppEmail" ref="loginUsername" v-model="usernameInput"
                placeholder="${msg('placeholderLoginName')}" name="username" autocomplete="username"
                :disabled="<#if usernameEditDisabled??>true<#else>false</#if>" autofocus @input="usernameInput = sanitizeHtml(usernameInput)"></unnnic-input>
        </unnnic-form-element>

        <unnnic-form-element label="${msg('password')}">
            <unnnic-input
                ref="password"
                v-model="passwordInput"
                :icon-right="loginPasswordVisible ? 'visibility_off' : 'visibility'"
                icon-right-clickable
                :native-type="loginPasswordVisible ? 'text' : 'password'"
                placeholder="${msg('placeholderLoginPassword')}"
                name="password"
                autocomplete="current-password"
                @input="passwordInput = sanitizeHtml(passwordInput)"
                @icon-right-click="toggleLoginPasswordVisibility"
            ></unnnic-input>
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
                <input type="hidden" name="rememberMe" :value="rememberMe ? 'on' : 'off'" />
                <unnnic-checkbox
                  v-model="rememberMe"
                  class="login-checkbox-remember-me"
                  :text-right="'${msg("rememberMe")}'"
                ></unnnic-checkbox>
            </#if>

            <#if realm.resetPasswordAllowed>
                <div class="forgot-password ${properties.kcInputMessageClass!}"><a tabindex="5"
                        href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a></div>
            </#if>
        </div>
    </form>
</#macro>