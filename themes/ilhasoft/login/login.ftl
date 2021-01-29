<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=social.displayInfo; section>
    <#if section = "title">
        ${msg("loginTitle",(realm.displayName!''))}
    <#elseif section = "header">
        ${msg("loginTitleHtml",(realm.displayNameHtml!''))?no_esc}
    <#elseif section = "form">
        <#if realm.password>
            <form id="kc-form-login" class="${properties.kcFormClass!}" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post">
                <div class="${properties.kcFormGroupClass!}">
                    <div class="${properties.kcLabelWrapperClass!}">
                        <label for="username" class="${properties.kcLabelClass!}"><#if !realm.loginWithEmailAllowed>${msg("username")}<#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}<#else>${msg("email")}</#if></label>
                    </div>

                    <div class="${properties.kcInputWrapperClass!} ${properties.kcInputControlClass!}">
                        <span class="icon icon-input icon-left icon-single-neutral-actions-1"></span>
                        <#if usernameEditDisabled??>
                            <input tabindex="1" id="username" class="${properties.kcInputClass!} has-icon-left" placeholder="${msg("placeholderLoginName")}" name="username" value="${(login.username!'')}" type="text" disabled />
                        <#else>
                            <input tabindex="1" id="username" class="${properties.kcInputClass!} has-icon-left" placeholder="${msg("placeholderLoginName")}" name="username" value="${(login.username!'')}" type="text" autofocus autocomplete="off" />
                        </#if>
                    </div>
                </div>

                <div class="${properties.kcFormGroupClass!}">
                    <div class="${properties.kcLabelWrapperClass!}">
                        <label for="password" class="${properties.kcLabelClass!}">${msg("password")}</label>
                    </div>

                    <div class="${properties.kcInputWrapperClass!} ${properties.kcInputControlClass!}">
                        <input tabindex="2" id="password" class="${properties.kcInputClass!} has-icon-left has-icon-right" placeholder="${msg("placeholderLoginPassword")}" name="password" type="password" autocomplete="off" />
                            <span class="icon icon-input icon-left icon-lock-2-1"></span>
                            <span id="password-icon" onclick="togglePassword()" class="icon icon-clickable icon-input icon-right icon-view-1-1"></span>
                            <#if realm.resetPasswordAllowed>
                                <div class="forgot-password ${properties.kcInputMessageClass!}"><a tabindex="5" href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a></div>
                            </#if>
                            <#if realm.rememberMe && !usernameEditDisabled??>
                            <div class="input-message">
                                <#if login.rememberMe??>
                                    <input id="rememberMe" tabindex="3" name="rememberMe" type="checkbox" tabindex="3" checked> ${msg("rememberMe")}
                                <#else>
                                    <input id="rememberMe" tabindex="3" name="rememberMe" type="checkbox" tabindex="3"> ${msg("rememberMe")}
                                </#if>
                            </div>
                        </#if>
                        </div>
                    </div>
                </div>

                <div class="${properties.kcFormGroupClass!}">
                    <div id="kc-form-options" class="${properties.kcFormOptionsClass!}">
                        
                    </div>

                    <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                        <div class="${properties.kcFormButtonsWrapperClass!}">
                            <input tabindex="4" class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}" name="login" id="kc-login" type="submit" value="${msg("doLogIn")}"/>
                        </div>
                     </div>
                </div>
            </form>
        </#if>
    <#elseif section = "info" >
        <#if realm.password && realm.registrationAllowed && !usernameEditDisabled??>
            <div id="kc-registration">
                <span>${msg("noAccount")} <a tabindex="6" href="${url.registrationUrl}">${msg("doRegister")}</a></span>
            </div>
        </#if>
    </#if>
</@layout.registrationLayout>
