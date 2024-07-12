<#import "template.ftl" as layout>
    <#import "login-form.ftl" as loginLayout>
        <@layout.registrationLayout displayInfo=social.displayInfo displayLoginFormScriptsAndStyles=true; section>
            <#if section="title">
                ${msg("loginTitle",(realm.displayName!''))}
                <#elseif section="header">
                    ${msg("loginTitleHtml",(realm.displayNameHtml!''))?no_esc}
                    <#elseif section="form">
                        <#if realm.password>
                            <@loginLayout.loginLayout></@loginLayout.loginLayout>
                        </#if>
                        <#elseif section="info">
                            <#if realm.password && realm.registrationAllowed && !usernameEditDisabled??>
                                <div id="separator-group">
                                    <div class="separator"></div>
                                    <span class="separator-text"> ${msg("separatorMessage")} </span>
                                    <div class="separator"></div>
                                </div>

                                <div id="kc-registration">
                                    <#-- <input
                                        class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}"
                                        name="login" id="kc-login" ref="kc-login" type="submit" value="${msg("
                                        doLogIn")}" /> -->
                                    <unnnic-button class="sign-up-button" size="small"
                                        text="${msg('doRegisterForFree')}" type="terciary"
                                        @click.prevent="location.href = '${url.registrationUrl}'"></unnnic-button>
                                </div>
                            </#if>
                            <div class="footer">
                                <a class="privacy-policy" target="_blank" href="${properties.urlPrivacyPolicy!}">
                                    ${msg('termsOfService')}
                                </a>
                            </div>
            </#if>
        </@layout.registrationLayout>