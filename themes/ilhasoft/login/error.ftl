<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=false; section>
    <#if section = "title">
        ${msg("errorTitle")}
    <#elseif section = "header">
        ${msg("errorTitle")}
    <#elseif section = "form">
        <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
            <unnnic-button
                class="login-button"
                size="large"
                text="${msg('doBackToLogin')}"
                type="secondary"
                @click.prevent="navigateTo('${url.loginRestartFlowUrl}')"
            ></unnnic-button>
        </div>
    </#if>
</@layout.registrationLayout>
