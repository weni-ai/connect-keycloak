<#import "template.ftl" as layout>
<#import "login-form.ftl" as loginLayout>
<@layout.registrationLayout displayInfo=social.displayInfo displayLoginFormScriptsAndStyles=true; section>
    <#if section = "title">
        ${msg("loginTitle",(realm.displayName!''))}
    <#elseif section = "header">
        ${msg("loginTitleHtml",(realm.displayNameHtml!''))?no_esc}
    <#elseif section = "form">
            <div id="modal" class="modal-background">
            <div class="modal-container">
                <div class="modal-content">
                    <div class="modal-button-container">
                        <span class="icon-clickable" onclick="closeModal('verifyEmail')">
                            <unnnic-icon icon="close" scheme="neutral-darkest" size="sm"></unnnic-icon>
                        </span>
                    </div>
                <div class="modal-center-icon">
                    <unnnic-icon icon="error" scheme="fg-critical" size="xl"></unnnic-icon>
                </div>
                <div class="modal-title">${msg("emailVerifyTitle")}</div>
                <div class="modal-text">${msg("emailVerifyInstruction1")}</div>
            </div>
            <div class="modal-message">${msg("emailVerifyInstruction2")} <a href="${url.loginAction}">${msg("emailVerifyInstruction3")}</a></div>
        </div>
        </div>
        <#if realm.password>
            <@loginLayout.loginLayout></@loginLayout.loginLayout>
        </#if>
    <#elseif section = "info" >
        <#if realm.password && realm.registrationAllowed && !usernameEditDisabled??>
            <div id="kc-registration">
                <span>${msg("noAccount")} <a tabindex="6" href="${url.registrationUrl}">${msg("doRegister")}</a></span>
            </div>
        </#if>
    </#if>
</@layout.registrationLayout>