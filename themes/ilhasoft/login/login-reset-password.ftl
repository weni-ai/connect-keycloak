<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true; section>
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
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="username" class="${properties.kcLabelClass!}"><#if !realm.loginWithEmailAllowed>${msg("username")}<#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}<#else>${msg("email")}</#if></label>
                </div>
                <div class="${properties.kcInputWrapperClass!} ${properties.kcInputControlClass!}">
                    <span class="icon icon-input icon-left icon-email-action-unread-1"></span>
                    <input type="text" id="username" placeholder="${msg("placeholderLoginReset")}" name="username" class="${properties.kcInputClass!} ${messagesPerField.printIfExists('username',properties.kcFormGroupErrorClass!)} has-icon-left" autofocus/>
                </div>
            </div>

                <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                    <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("doSubmit")}"/>
                </div>
            </div>

            <div id="kc-info-wrapper" class="back-link">
                <span>${msg("alreadyAccountReset")} <a href="${url.loginUrl}">${msg("backToLogin")?no_esc}</a></span>
            </div>
        </form>
    </#if>
</@layout.registrationLayout>
