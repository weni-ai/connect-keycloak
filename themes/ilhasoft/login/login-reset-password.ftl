<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=false; section>
    <#if section = "title">
        ${msg("emailForgotTitle")}
    <#elseif section = "header">
        ${msg("emailForgotTitle")}
    <#elseif section = "form">
        <div class="greetings">
            ${msg("greetings")}
        </div>
        <div class="form-header">
            ${msg("loginResetInstructions")}
        </div>
        <form id="kc-reset-password-form" class="${properties.kcFormClass!}" action="${url.loginAction}" method="post">
            <div class="${properties.kcFormGroupClass!}">
                <unnnic-form-element
                    label="<#if !realm.loginWithEmailAllowed>${msg('username')}<#elseif !realm.registrationEmailAsUsername>${msg('usernameOrEmail')}<#else>${msg('email')}</#if>"
                >
                    <unnnic-input
                        ref="username"
                        v-model="usernameInput"
                        @input="usernameInput = sanitizeHtml(usernameInput)"
                        placeholder="${msg('placeholderLoginReset')}"
                        name="username"
                        :type="'${messagesPerField.printIfExists('username',properties.kcFormGroupErrorClass!)}' ? 'error' : 'normal'"
                        autofocus
                    ></unnnic-input>
                </unnnic-form-element>
            </div>

                <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!} reset-password-buttons">
                    <unnnic-button class="" size="large"
                    text="${msg('cancel')}" type="terciary"
                    @click.prevent="location.href = '${url.loginUrl}'"></unnnic-button>
                    <unnnic-button id="required-input-button" class="login-button" size="large" text="${msg('confirm')}"
                    type="primary" native-type="submit" :disabled="!isEmailValid(usernameInput)"></unnnic-button>
                </div>
            </div>

            <section class="sign-up-button-container">
                <section>
                    <p class="sign-up-button-text">${msg('signUpForFree')}</p>
                </section>
                <unnnic-button class="sign-up-button" size="large"
                text="${msg('doRegisterForFree')}" type="terciary"
                @click.prevent="location.href = '${url.registrationUrl}'"></unnnic-button>
            </section>
            <div class="footer">
                <a class="privacy-policy" target="_blank" href="${properties.urlPrivacyPolicy!}">
                    ${msg('termsOfService')}
                </a>
            </div>
        </form>
    </#if>
</@layout.registrationLayout>
