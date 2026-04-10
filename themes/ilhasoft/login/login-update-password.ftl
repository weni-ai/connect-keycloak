<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=false; section>
    <#if section = "form">
        <h2 class="login-title">${msg("updatePasswordTitle")}</h2>
        <form id="kc-passwd-update-form" class="${properties.kcFormClass!}" action="${url.loginAction}" method="post">
            <input type="text" id="username" name="username" value="${username}" autocomplete="username"
                   readonly="readonly" style="display:none;"/>
            <input type="password" id="password" name="password" autocomplete="current-password" style="display:none;"/>

            <div class="${properties.kcFormGroupClass!}">
                <unnnic-form-element label="${msg('passwordNew')}">
                    <unnnic-input
                        v-model="newPasswordInput"
                        :icon-right="newPasswordVisible ? 'visibility_off' : 'visibility'"
                        icon-right-clickable
                        :native-type="newPasswordVisible ? 'text' : 'password'"
                        placeholder=""
                        name="password-new"
                        autofocus
                        autocomplete="new-password"
                        @icon-right-click="toggleNewPasswordVisibility"
                    ></unnnic-input>
                </unnnic-form-element>
            </div>

            <div class="${properties.kcFormGroupClass!}">
                <unnnic-form-element label="${msg('passwordConfirm')}">
                    <unnnic-input
                        v-model="confirmPasswordInput"
                        :icon-right="confirmPasswordVisible ? 'visibility_off' : 'visibility'"
                        icon-right-clickable
                        :native-type="confirmPasswordVisible ? 'text' : 'password'"
                        placeholder=""
                        name="password-confirm"
                        autocomplete="new-password"
                        @icon-right-click="toggleConfirmPasswordVisibility"
                    ></unnnic-input>
                </unnnic-form-element>
            </div>

            <#if isAppInitiatedAction??>
                <div class="${properties.kcFormGroupClass!}">
                    <input type="hidden" name="logout-sessions" :value="logoutSessions ? 'on' : 'off'" />
                    <unnnic-checkbox
                      v-model="logoutSessions"
                      :text-right="'${msg("logoutOtherSessions")}'"
                    ></unnnic-checkbox>
                </div>
            </#if>

            <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!} update-password-buttons">
                <#if isAppInitiatedAction??>
                    <unnnic-button
                        size="large"
                        text="${msg('cancel')}"
                        type="secondary"
                        native-type="submit"
                        name="cancel-aia"
                        value="true"
                    ></unnnic-button>
                    <unnnic-button
                        size="large"
                        text="${msg('confirm')}"
                        type="primary"
                        native-type="submit"
                        :disabled="!canUpdatePassword"
                    ></unnnic-button>
                <#else>
                    <unnnic-button
                        class="login-button"
                        size="large"
                        text="${msg('confirm')}"
                        type="primary"
                        native-type="submit"
                        :disabled="!canUpdatePassword"
                    ></unnnic-button>
                </#if>
            </div>

            <footer class="footer">
                <a class="privacy-policy" target="_blank" href="${properties.urlPrivacyPolicy!}">
                    ${msg('termsOfService')}
                </a>
            </footer>
        </form>
    </#if>
</@layout.registrationLayout>