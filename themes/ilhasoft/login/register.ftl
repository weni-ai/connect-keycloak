<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false; section>
    <#if section = "header">
        ${msg("registerTitle")}
    <#elseif section = "form">
        <form id="kc-register-form" class="${properties.kcFormClass!}" action="${url.registrationAction}" method="post">
            <div class="${properties.kcFormGroupClass!} ${messagesPerField.printIfExists('firstName',properties.kcFormGroupErrorClass!)}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="firstName" class="${properties.kcLabelClass!}">${msg("firstName")}</label>
                </div>
                <div class="${properties.kcInputWrapperClass!} ${properties.kcInputControlClass!}">
                    <span class="icon icon-input icon-left icon-read-email-at-1"></span>
                    <input type="text" id="firstName" class="has-icon-left ${properties.kcInputClass!}" placeholder="${msg("placeholderRegisterFirstName")}" name="firstName" value="${(register.formData.firstName!'')}" />
                    <div class="${properties.kcInputMessageClass!}"> ${messagesPerField.get('firstName')} </div>
                </div>
            </div>

            <div class="${properties.kcFormGroupClass!} ${messagesPerField.printIfExists('lastName',properties.kcFormGroupErrorClass!)}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="lastName" class="${properties.kcLabelClass!}">${msg("lastName")}</label>
                </div>
                <div class="${properties.kcInputWrapperClass!} ${properties.kcInputControlClass!}">
                    <span class="icon icon-input icon-left icon-single-neutral-actions-1"></span>
                    <input type="text" id="lastName" class="has-icon-left ${properties.kcInputClass!}" placeholder="${msg("placeholderRegisterLastName")}" name="lastName" value="${(register.formData.lastName!'')}" />
                    <div class="${properties.kcInputMessageClass!}"> ${messagesPerField.get('lastName')} </div>
                </div>
            </div>

            <div class="${properties.kcFormGroupClass!} ${messagesPerField.printIfExists('email',properties.kcFormGroupErrorClass!)}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="email" class="${properties.kcLabelClass!}">${msg("email")}</label>
                </div>
                <div class="${properties.kcInputWrapperClass!} ${properties.kcInputControlClass!}">
                    <span class="icon icon-input icon-left icon-lock-2-1"></span>
                    <input type="text" id="email" class="has-icon-left ${properties.kcInputClass!}" placeholder="${msg("placeholderRegisterEmail")}" name="email" value="${(register.formData.email!'')}" autocomplete="email" />
                    <div class="${properties.kcInputMessageClass!}"> ${messagesPerField.get('email')} </div>
                </div>
            </div>

            <div class="form-group-nested">

                <div class="${properties.kcFormGroupClass!} ${messagesPerField.printIfExists('nickname',properties.kcFormGroupErrorClass!)}">
                    <div class="${properties.kcLabelWrapperClass!}">
                        <label for="user.attributes.nickname" class="${properties.kcLabelClass!}">${msg("nickname")}</label>
                    </div>
                    <div class="${properties.kcInputWrapperClass!} ${properties.kcInputControlClass!}">
                        <span class="icon icon-input icon-left icon-read-email-at-1"></span>
                        <input type="text" id="user.attributes.nickname" class="has-icon-left ${properties.kcInputClass!}" placeholder="${msg("placeholderRegisterNickname")}" name="user.attributes.nickname" value="${(register.formData['user.attributes.nickname']!'')}" />
                        <div class="${properties.kcInputMessageClass!}"> ${messagesPerField.get('nickname')} </div>
                    </div>
                </div>

            <#if passwordRequired??>
                <div class="${properties.kcFormGroupClass!} ${messagesPerField.printIfExists('password',properties.kcFormGroupErrorClass!)}">
                    <div class="${properties.kcLabelWrapperClass!}">
                        <label for="password" class="${properties.kcLabelClass!}">${msg("password")}</label>
                    </div>
                    <div class="${properties.kcInputWrapperClass!} ${properties.kcInputControlClass!}">
                        <span class="icon icon-input icon-left icon-lock-2-1"></span>
                            <span onclick="togglePassword()" id="password-icon" class="icon icon-input icon-clickable icon-right icon-view-1-1"></span>
                            <input type="password" id="password" class="has-icon-left has-icon-right ${properties.kcInputClass!}" placeholder="${msg("placeholderRegisterPassword")}" name="password" autocomplete="new-password"/>
                        <div class="${properties.kcInputMessageClass!}"> ${messagesPerField.get('password')} </div>
                    </div>
                </div>
            </div>

                <div class="${properties.kcFormGroupClass!} ${messagesPerField.printIfExists('password-confirm',properties.kcFormGroupErrorClass!)}">
                    <div class="${properties.kcLabelWrapperClass!}">
                        <label for="password-confirm" class="${properties.kcLabelClass!}">${msg("passwordConfirm")}</label>
                    </div>
                    <div class="${properties.kcInputWrapperClass!} ${properties.kcInputControlClass!}">
                        <span class="icon icon-input icon-left icon-lock-2-1"></span>
                        <input type="password" id="password-confirm" class="has-icon-left ${properties.kcInputClass!}" placeholder="${msg("placeholderRegisterPasswordConfirm")}" name="password-confirm" />
                        <div class="${properties.kcInputMessageClass!}"> ${messagesPerField.get('passwordConfirm')} </div>
                    </div>
                </div>
            </#if>

            <#if recaptchaRequired??>
                <div class="form-group">
                    <div class="${properties.kcInputWrapperClass!}">
                        <div class="g-recaptcha" data-size="compact" data-sitekey="${recaptchaSiteKey}"></div>
                    </div>
                </div>
            </#if>

                <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                    <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("doRegister")}"/>
                </div>
            </div>

            <div id="kc-info-wrapper" class="back-link">
                <span>${msg("alreadyAccount")} <a href="${url.loginUrl}">${msg("backToLogin")?no_esc}</a></span>
            </div>
        </form>
    </#if>
</@layout.registrationLayout>