<#import "template.ftl" as layout>
    <@layout.registrationLayout displayMessage=false displayRegisterScriptsAndStyles=true; section>
        <#if section="header">
            ${msg("registerTitle")}
            <#elseif section="form">
                <div class="greetings">
                    ${msg("register_greetings")}
                </div>
                <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}" style="text-align: right;">
                    <div class="${properties.kcFormButtonsWrapperClass!} login-buttons">
                        <#if realm.password?? && social.providers??>
                            <#list social.providers as p>
                                <a id="zocial-${p.alias}" class="social-link" href="${p.loginUrl}">
                                    <button type="button" class="social-button button-control"
                                        id="button-${p.alias}">
                                        <img src="${url.resourcesPath}/img/login/icon-${p.alias}.svg"
                                            class="icon-image icon-button-left">
                                    </button>
                                </a>
                            </#list>
                        </#if>
                    </div> 
                </div>
                <div id="separator-group">
                    <div class="separator"></div>
                    <span class="separator-text">${msg("separatorRegisterMessage")}</span>
                    <div class="separator"></div>
                </div>

                <form id="kc-register-form" class="${properties.kcFormClass!}" action="${url.registrationAction}"
                    method="post">
                    <!-- <unnnic-form-element
                label="${msg('firstName')}"
                error="${messagesPerField.get('firstName')}"
                class="register-form-row-email"
            >
                <unnnic-input
                    v-model="firstName"
                    icon-left="single-neutral-actions-1"
                    placeholder="${msg('placeholderRegisterFirstName')}"
                    name="firstName"
                    :type="'${messagesPerField.get('firstName')}' ? 'error' : 'normal'"
                ></unnnic-input>
            </unnnic-form-element>

            <unnnic-form-element
                label="${msg('lastName')}"  
                error="${messagesPerField.get('lastName')}"
                class="register-form-row-email"
            >
                <unnnic-input
                    v-model="lastName"
                    icon-left="single-neutral-actions-1"
                    placeholder="${msg('placeholderRegisterLastName')}"
                    name="lastName"
                    :type="'${messagesPerField.get('lastName')}' ? 'error' : 'normal'"
                ></unnnic-input>
            </unnnic-form-element> -->

                    <div class="register-form-row-email">
                        <unnnic-form-element label="${msg('email')}" error="${messagesPerField.get('email')}">
                            <unnnic-input v-model="email"
                                class="register-form-row-email-input"
                                placeholder="${msg('placeholderRegisterEmail')}" name="email" autocomplete="email"
                                :type="'${messagesPerField.get('email')}' ? 'error' : 'normal'" @input="email = sanitizeHtml(email)"></unnnic-input>
                        </unnnic-form-element>
                    </div>

                    <div class="register-form-row-password">
                        <unnnic-form-element label="${msg('password')}"
                            :error="'${messagesPerField.get('password')}' ? '${messagesPerField.get('password')}' : false">

                            <unnnic-input ref="registerPassword" v-model="password" native-type="password"
                             placeholder="${msg('placeholderRegisterPassword')}" name="password"
                                autocomplete="password"
                                :type="'${messagesPerField.get('password')}' ? 'error' : 'normal'"
                                allow-toggle-password @input="password = sanitizeHtml(password)"></unnnic-input>

                            <div class="password-strength-rules">
                                <div class="password-strength-columns">
                                    <div class="password-strength-column">
                                        <div class="rule" :class="{ 'valid': passwordRules.lowercase }">
                                            <unnnic-icon icon="check-circle-1-1-1" fill="true" size="sm" :scheme="passwordRules.lowercase ? 'feedback-green' : 'neutral-cleanest'"></unnnic-icon>
                                            <span>${msg('password_step_1')}</span>
                                        </div>
                                        <div class="rule" :class="{ 'valid': passwordRules.uppercase }">
                                            <unnnic-icon icon="check-circle-1-1-1" size="sm" :scheme="passwordRules.uppercase ? 'feedback-green' : 'neutral-cleanest'"></unnnic-icon>
                                            <span>${msg('password_step_2')}</span>
                                        </div>
                                        <div class="rule" :class="{ 'valid': passwordRules.number }">
                                            <unnnic-icon icon="check-circle-1-1-1" size="sm" :scheme="passwordRules.number ? 'feedback-green' : 'neutral-cleanest'"></unnnic-icon>
                                            <span>${msg('password_step_5')}</span>
                                        </div>
                                    </div>
                                    <div class="password-strength-column">
                                        <div class="rule" :class="{ 'valid': passwordRules.specialChar }">
                                            <unnnic-icon icon="check-circle-1-1-1" size="sm" :scheme="passwordRules.specialChar ? 'feedback-green' : 'neutral-cleanest'"></unnnic-icon>
                                            <span>${msg('password_step_3')}</span>
                                        </div>
                                        <div class="rule" :class="{ 'valid': passwordRules.minLength }">
                                            <unnnic-icon icon="check-circle-1-1-1" size="sm" :scheme="passwordRules.minLength ? 'feedback-green' : 'neutral-cleanest'"></unnnic-icon>
                                            <span>${msg('password_step_4')}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </unnnic-form-element>
                    </div>

                    <div class="register-form-row-password-confirm" v-if="(passwordRules.lowercase && passwordRules.uppercase && passwordRules.number && passwordRules.specialChar && passwordRules.minLength) || ${messagesPerField.exists('email')?c} || ${messagesPerField.exists('password')?c} || ${messagesPerField.exists('password-confirm')?c}">
                        <#if passwordRequired??>
                            <unnnic-form-element label="${msg('passwordConfirm')}"
                                error="${messagesPerField.get('password-confirm')}">
                                <unnnic-input ref="registerPasswordConfirm" v-model="passwordConfirm"
                                    native-type="password"
                                    placeholder="${msg('placeholderRegisterPasswordConfirm')}" name="password-confirm"
                                    autocomplete="password"
                                    :type="`${messagesPerField.get('password-confirm')}` ? 'error' : 'normal'"
                                    allow-toggle-password @input="passwordConfirm = sanitizeHtml(passwordConfirm)"></unnnic-input>
                            </unnnic-form-element>
                        </#if>
                    </div>

                    <#if !realm.registrationEmailAsUsername>
                        <div ref="username"
                            class="input-medium ${messagesPerField.printIfExists('username', properties.kcFormGroupErrorClass!)}">
                            <label for="username">
                                <div class="label">${msg("username")}</div>

                                <div class="input">
                                    <div class="icon left">
                                        <#include "resources/img/login/read-email-at-1.svg">
                                    </div>

                                    <input type="text" id="username" placeholder="${msg('placeholderRegisterUsername')}"
                                        name="username" v-model="username" autocomplete="username" />
                                </div>

                                <div class="${properties.kcInputMessageClass!}"> ${messagesPerField.get('username')}
                                </div>
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
                        <unnnic-button class="login-button" size="large" text="${msg('createAccount')}" type="primary"
                            :disabled="!email || !password || !passwordRules.lowercase || !passwordRules.uppercase || !passwordRules.number || !passwordRules.specialChar || !passwordRules.minLength || !passwordConfirm || password !== passwordConfirm"></unnnic-button>
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