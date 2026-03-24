<#import "template.ftl" as layout>
<#import "login-form.ftl" as loginLayout>
<@layout.registrationLayout displayInfo=social.displayInfo displayLoginFormScriptsAndStyles=true; section>
    <#if section = "title">
        ${msg("loginTitle",(realm.displayName!''))}
    <#elseif section = "header">
        ${msg("loginTitleHtml",(realm.displayNameHtml!''))?no_esc}
    <#elseif section = "form">
        <unnnic-dialog :open="true" @update:open="navigateTo('${url.loginRestartFlowUrl}')">
            <unnnic-dialog-content size="small">
                <unnnic-dialog-header type="attention">
                    <unnnic-dialog-title>${msg("emailVerifyTitle")}</unnnic-dialog-title>
                </unnnic-dialog-header>
                <div class="verify-email-modal-body">
                    <p>${msg("emailVerifyInstruction1")}</p>
                    <p class="verify-email-modal-resend">
                        ${msg("emailVerifyInstruction2")}
                        <a href="${url.loginAction}">${msg("emailVerifyInstruction3")}</a>
                    </p>
                </div>
            </unnnic-dialog-content>
        </unnnic-dialog>
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