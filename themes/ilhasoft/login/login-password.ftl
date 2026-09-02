<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=false displayMessage=!messagesPerField.existsError('password') displayPasswordFormScriptsAndStyles=true; section>
    <#if section = "title">
        ${msg("loginTitle",(realm.displayName!''))}
    <#elseif section = "header">
        ${msg("loginTitleHtml",(realm.displayNameHtml!''))?no_esc}
    <#elseif section = "form">
        <div class="login-password">
            <h2 class="login-title">${msg("loginPasswordTitle")}</h2>
            <#if auth?has_content && auth.showUsername()>
                <div class="login-password-identity">
                    <span class="login-password-attempted-username">${auth.attemptedUsername}</span>
                    <a class="login-password-change-email" href="${url.loginRestartFlowUrl}">${msg("doChangeEmail")}</a>
                </div>
            </#if>
            <form id="kc-form-login" class="${properties.kcFormClass!}" action="${url.loginAction}" method="post" @submit="submitting = true">
                <unnnic-form-element
                    label="${msg('password')}"
                    error="${messagesPerField.get('password')}"
                    <#if messagesPerField.existsError('password')>role="alert"</#if>
                >
                    <unnnic-input
                        ref="password"
                        v-model="passwordInput"
                        :icon-right="loginPasswordVisible ? 'visibility_off' : 'visibility'"
                        icon-right-clickable
                        :native-type="loginPasswordVisible ? 'text' : 'password'"
                        placeholder="${msg('placeholderLoginPassword')}"
                        name="password"
                        autocomplete="current-password"
                        :type="'${messagesPerField.printIfExists('password',properties.kcFormGroupErrorClass!)}' ? 'error' : 'normal'"
                        autofocus
                        @input="passwordInput = sanitizeHtml(passwordInput)"
                        @icon-right-click="toggleLoginPasswordVisibility"
                    ></unnnic-input>
                    <button
                        type="button"
                        class="login-password-toggle"
                        :aria-label="loginPasswordVisible ? '${msg('hidePassword')}' : '${msg('showPassword')}'"
                        @click="toggleLoginPasswordVisibility"
                    >{{ loginPasswordVisible ? '${msg('hidePassword')}' : '${msg('showPassword')}' }}</button>
                </unnnic-form-element>
                <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                    <unnnic-button
                        class="login-button"
                        size="large"
                        text="${msg('doLogIn')}"
                        type="primary"
                        native-type="submit"
                        :disabled="submitting || !canSubmitPassword"
                    ></unnnic-button>
                </div>
                <#if realm.resetPasswordAllowed>
                    <div class="forgot-password ${properties.kcInputMessageClass!}"><a tabindex="5"
                            href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a></div>
                </#if>
            </form>
        </div>
    </#if>
</@layout.registrationLayout>
