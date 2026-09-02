<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true displayMessage=!messagesPerField.existsError('username') displayUsernameFormScriptsAndStyles=true; section>
    <#if section = "title">
        ${msg("loginTitle",(realm.displayName!''))}
    <#elseif section = "header">
        ${msg("loginTitleHtml",(realm.displayNameHtml!''))?no_esc}
    <#elseif section = "form">
        <div class="login-username">
            <h2 class="login-title">${msg("loginFormTitle")}</h2>
            <form id="kc-form-login" class="${properties.kcFormClass!}" action="${url.loginAction}" method="post" @submit="submitting = true">
                <#if !usernameHidden??>
                    <unnnic-form-element
                        label="<#if !realm.loginWithEmailAllowed>${msg('username')}<#elseif !realm.registrationEmailAsUsername>${msg('usernameOrEmail')}<#else>${msg('email')}</#if>"
                        error="${messagesPerField.get('username')}"
                        <#if messagesPerField.existsError('username')>role="alert"</#if>
                    >
                        <unnnic-input
                            :disabled="!!VTEXAppEmail"
                            ref="loginUsername"
                            v-model="usernameInput"
                            placeholder="<#if realm.registrationEmailAsUsername>${msg('placeholderLoginEmail')}<#else>${msg('placeholderLoginName')}</#if>"
                            name="username"
                            autocomplete="<#if realm.registrationEmailAsUsername>email<#else>username</#if>"
                            :type="'${messagesPerField.printIfExists('username',properties.kcFormGroupErrorClass!)}' ? 'error' : 'normal'"
                            autofocus
                            @input="usernameInput = sanitizeHtml(usernameInput)"
                        ></unnnic-input>
                    </unnnic-form-element>
                </#if>
                <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                    <unnnic-button
                        class="login-button"
                        size="large"
                        text="${msg('doLogIn')}"
                        type="primary"
                        native-type="submit"
                        :disabled="submitting || !canSubmitUsername"
                    ></unnnic-button>
                </div>
            </form>
        </div>
    <#elseif section = "info">
        <div class="login-username">
            <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
                <#if social.providers?? && social.providers?has_content>
                    <div v-if="!VTEXAppEmail" id="separator-group">
                        <div class="separator"></div>
                        <span class="separator-text">${msg("separatorMessage")}</span>
                        <div class="separator"></div>
                    </div>
                </#if>
                <section class="social-login-container">
                    <#if realm.password?? && social.providers??>
                    <#list social.providers as p>
                        <unnnic-button
                            id="zocial-${p.alias}"
                            class="social-button"
                            type="secondary"
                            size="large"
                            aria-label="${msg('loginWith')} ${p.displayName!p.alias}"
                            @click.prevent="navigateTo('${p.loginUrl}')"
                        >
                            <img src="${url.resourcesPath}/img/login/icon-${p.alias}.svg"
                                class="icon-image">
                        </unnnic-button>
                    </#list>
                    </#if>
                </section>
                <div v-if="!VTEXAppEmail" id="kc-registration">
                    <section class="sign-up-button-container">
                        <p class="sign-up-button-text">${msg('signUpForFree')}</p>
                        <unnnic-button class="sign-up-button" size="large"
                            text="${msg('doRegisterForFree')}" type="secondary"
                            @click.prevent="navigateTo('${url.registrationUrl}')"></unnnic-button>
                    </section>
                </div>
            </#if>
            <div class="footer">
                <a class="privacy-policy" target="_blank" href="${properties.urlPrivacyPolicy!}">
                    ${msg('termsOfService')}
                </a>
            </div>
        </div>
    </#if>
</@layout.registrationLayout>
