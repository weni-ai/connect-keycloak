<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=false; section>
    <#if section = "title">
        ${msg("emailForgotTitle")}
    <#elseif section = "header">
        ${msg("emailForgotTitle")}
    <#elseif section = "form">
        <div class="form-header">
            ${msg("emailInstruction")}
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
                        icon-left="email-action-unread-1"
                        placeholder="${msg('placeholderLoginReset')}"
                        name="username"
                        :type="'${messagesPerField.printIfExists('username',properties.kcFormGroupErrorClass!)}' ? 'error' : 'normal'"
                        autofocus
                    ></unnnic-input>
                </unnnic-form-element>
            </div>

                <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                    <input id="required-input-button" class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("doSubmit")}"/>
                </div>
            </div>

            <div id="kc-info-wrapper" class="back-link">
                <span>${msg("alreadyAccountReset")} <a href="${url.loginUrl}">${msg("backToLogin")?no_esc}</a></span>
            </div>
        </form>
    </#if>
</@layout.registrationLayout>
