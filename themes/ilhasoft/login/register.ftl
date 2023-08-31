<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false displayRegisterScriptsAndStyles=true; section>
    <#if section = "header">
        ${msg("registerTitle")}
    <#elseif section = "form">
        <div class="greetings">
            <a href="${url.loginUrl}">
                <img class="brand-title" src="${url.resourcesPath}/img/login/Weni-Logo-Blue.svg">
            </a>

            ${msg("register_greetings")}
        </div>
        <form id="kc-register-form" class="${properties.kcFormClass!}" action="${url.registrationAction}" method="post">
            <div class="register-form-row-email">
                <unnnic-form-element
                    label="${msg('email')}"
                    error="${messagesPerField.get('email')}"
                >
                    <unnnic-input
                        v-model="email"
                        icon-left="email-action-unread-1"
                        placeholder="${msg('placeholderRegisterEmail')}"
                        name="email"
                        autocomplete="email"
                        :type="'${messagesPerField.get('email')}' ? 'error' : 'normal'"
                    ></unnnic-input>
                </unnnic-form-element>
            </div>

            <div class="register-form-row-password">
                <unnnic-form-element
                    label="${msg('password')}"
                    :error="'${messagesPerField.get('password')}' ? '${msg('password_instructions_title')}' : false"
                    :message="'${messagesPerField.get('password')}' ? undefined : '${msg('password_instructions_title')}'"
                >
                
                    <unnnic-input
                        ref="registerPassword"
                        v-model="password"
                        native-type="password"
                        icon-left="lock-2-1"
                        placeholder="${msg('placeholderRegisterPassword')}"
                        name="password"
                        autocomplete="password"
                        :type="'${messagesPerField.get('password')}' ? 'error' : 'normal'"
                        allow-toggle-password
                    ></unnnic-input>
                </unnnic-form-element>

                <#if passwordRequired??>
                    <unnnic-form-element
                        label="${msg('passwordConfirm')}"
                        error="${messagesPerField.get('password-confirm')}"
                    >
                        <unnnic-input
                            ref="registerPasswordConfirm"
                            v-model="passwordConfirm"
                            native-type="password"
                            icon-left="lock-2-1"
                            placeholder="${msg('placeholderRegisterPasswordConfirm')}"
                            name="password-confirm"
                            autocomplete="password"
                            :type="`${messagesPerField.get('password-confirm')}` ? 'error' : 'normal'"
                            allow-toggle-password
                        ></unnnic-input>
                    </unnnic-form-element>
                </#if>

                <div v-if="password.length && registerPasswordFocused" class="password-strength">
                    <div class="title">
                        {{
                            password.length < 8 ? '${msg('password_level_1')}' :
                            ['${msg('password_level_2')}', '${msg('password_level_3')}', '${msg('password_level_4')}'][[/[a-z]/.test(password), /[A-Z]/.test(password), /[@$!%*?&#]/.test(password)].filter(i => i).length - 1]
                        }}
                    </div>

                    <div class="bar">
                        <div :class="['progress', 'fulfilled-' + (password.length < 8 ? '0' : [/[a-z]/.test(password), /[A-Z]/.test(password), /[@$!%*?&#]/.test(password)].filter(i => i).length)]"></div>
                    </div>
                </div>
            </div>

            <#if !realm.registrationEmailAsUsername>
                <div ref="username" class="input-medium ${messagesPerField.printIfExists('username', properties.kcFormGroupErrorClass!)}">
                    <label for="username">
                        <div class="label">${msg("username")}</div>

                        <div class="input">
                            <div class="icon left">
                                <#include "resources/img/login/read-email-at-1.svg">
                            </div>

                            <input
                                type="text"
                                id="username"
                                placeholder="${msg('placeholderRegisterUsername')}"
                                name="username"
                                v-model="username"
                                autocomplete="username"
                            />
                        </div>

                        <div class="${properties.kcInputMessageClass!}"> ${messagesPerField.get('username')} </div>
                    </label>
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
                    <unnnic-button
                        class="login-button"
                        size="small"
                        text="${msg('doRegister')}"
                        type="primary"
                        :disabled="!email || !password || !passwordConfirm"
                    ></unnnic-button>
                </div>

                <div id="separator-group">
                    <div class="separator"></div>
                    <span class="separator-text">${msg("separatorMessage")}</span>
                    <div class="separator"></div>
                </div>
        
                <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}" style="text-align: right;">
                    <div class="${properties.kcFormButtonsWrapperClass!} login-buttons">
                        <#if realm.password?? && social.providers??>
                            <#list social.providers as p>
                                <a id="zocial-${p.alias}" class="social-link" href="${p.loginUrl}">
                                    <button class="social-button button-control" id="button-${p.alias}">
                                        <img src="${url.resourcesPath}/img/login/icon-${p.alias}.svg" class="icon-image icon-button-left" >
                                        <span>${msg("loginWith")} ${p.displayName} </span>
                                    </button>
                                </a>
                            </#list>
                        </#if>
                    </div>
                </div>

            <div class="footer">
                <div class="back-to-login">
                    ${msg("alreadyAccount")}
                    <a href="${url.loginUrl}">${msg("backToLogin")?no_esc}</a>
                </div>

                <a class="privacy-policy" target="_blank" href="${properties.urlPrivacyPolicy!}">
                    ${msg('termsOfService')}
                </a>
            </div>
        </form>
    </#if>
</@layout.registrationLayout>