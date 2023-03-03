<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true displayHeader=false displaySocial=false; section>
    <#if section = "form">
        <img class="brand-password" src="${url.resourcesPath}/img/login/brand.svg" >
        <div class="update-password-title">
            ${msg("updatePasswordTitle")}
        </div>
        <form id="kc-passwd-update-form" class="${properties.kcFormClass!}" action="${url.loginAction}" method="post">
            <input type="text" id="username" name="username" value="${username}" autocomplete="username"
                   readonly="readonly" style="display:none;"/>
            <input type="password" id="password" name="password" autocomplete="current-password" style="display:none;"/>

            <div class="${properties.kcFormGroupClass!}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="password-new" class="${properties.kcLabelClass!}">${msg("passwordNew")}</label>
                </div>
                <div class="${properties.kcInputWrapperClass!} ${properties.kcInputControlClass!}">
                    <input type="password" id="password-new" name="password-new" class="${properties.kcInputClass!} has-icon-left has-icon-right"
                           autofocus autocomplete="new-password"
                    />
                    <span class="icon icon-input icon-left icon-lock-2-1"></span>
                    <span id="password-icon" onclick="togglePassword('password-icon', 'password-new')" class="icon icon-clickable icon-input icon-right icon-view-1-1"></span>
                        
                        <#--  this is with password  -->
                        <div class="${properties.kcInputMessageClass!}"> ${messagesPerField.get('password')} </div>

                        <#--  this is with passwordNew  -->
                        <div class="${properties.kcInputMessageClass!}"> ${messagesPerField.get('passwordNew')} </div>
                </div>
            </div>

            <div class="${properties.kcFormGroupClass!}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="password-confirm" class="${properties.kcLabelClass!}">${msg("passwordConfirm")}</label>
                </div>
                <div class="${properties.kcInputWrapperClass!} ${properties.kcInputControlClass!}">
                    <input type="password" id="password-confirm" name="password-confirm"
                           class="${properties.kcInputClass!} has-icon-left has-icon-right"
                           autocomplete="new-password"
                    />
                    <span class="icon icon-input icon-left icon-lock-2-1"></span>
                    <span id="password-icon-new" onclick="togglePassword('password-icon-new', 'new-password')" class="icon icon-clickable icon-input icon-right icon-view-1-1"></span>

                        <div class="${properties.kcInputMessageClass!}"> ${messagesPerField.get('password-confirm')} </div>
                </div>
            </div>

            <div class="${properties.kcFormGroupClass!}">
                <div id="kc-form-options" class="${properties.kcFormOptionsClass!}">
                    <div class="${properties.kcFormOptionsWrapperClass!}">
                        <#if isAppInitiatedAction??>
                            <div class="checkbox">
                                <label><input type="checkbox" id="logout-sessions" name="logout-sessions" value="on" checked> ${msg("logoutOtherSessions")}</label>
                            </div>
                        </#if>
                    </div>
                </div>

                <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                    <#if isAppInitiatedAction??>
                        <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("doSubmit")}" />
                        <button class="${properties.kcButtonClass!} ${properties.kcButtonDefaultClass!} ${properties.kcButtonLargeClass!}" type="submit" name="cancel-aia" value="true" />${msg("doCancel")}</button>
                    <#else>
                        <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("doSubmit")}" />
                    </#if>
                </div>
                <div class="password-back-link"> &larr; <a href="${properties.backUrl!}">${msg("backHome")}</span> </a>
            </div>
        </form>
    </#if>
</@layout.registrationLayout>