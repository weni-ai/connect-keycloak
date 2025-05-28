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
                                <div v-if="!VTEXAppEmail" id="separator-group">
                                    <div class="separator"></div>
                                    <span class="separator-text"> ${msg("separatorMessage")} </span>
                                    <div class="separator"></div>
                                </div>
                                <section class="social-login-container">
                                    <button type="button" class="social-button button-control" id="button-x">
                                        a
                                    </button>
                                    <button type="button" class="social-button button-control" id="button-x">
                                        b
                                    </button>
                                    <button type="button" class="social-button button-control" id="button-x">
                                        c
                                    </button>
                                    <#if realm.password?? && social.providers??>
                                    <#list social.providers as p>
                                        <a id="zocial-${p.alias}" class="social-link" href="${p.loginUrl}">
                                            <button type="button" class="social-button button-control" id="button-${p.alias}">
                                                <img src="${url.resourcesPath}/img/login/icon-${p.alias}.svg"
                                                    class="icon-image icon-button-left">
                                            </button>
                                        </a>
                                    </#list>
                                </#if>
                                </section>
                                <div v-if="!VTEXAppEmail" id="kc-registration">
                                    <#-- <input
                                        class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}"
                                        name="login" id="kc-login" ref="kc-login" type="submit" value="${msg("
                                        doLogIn")}" /> -->
                                        <section class="sign-up-button-container">
                                            <section>
                                                <p class="sign-up-button-text">${msg('signUpForFree')}</p>
                                            </section>
                                            <unnnic-button class="sign-up-button" size="large"
                                            text="${msg('doRegisterForFree')}" type="terciary"
                                            @click.prevent="location.href = '${url.registrationUrl}'"></unnnic-button>
                                        </section>
                                </div>
                            </#if>
                            <div class="footer">
                                <a class="privacy-policy" target="_blank" href="${properties.urlPrivacyPolicy!}">
                                    ${msg('termsOfService')}
                                </a>
                            </div>
            </#if>
        </@layout.registrationLayout>