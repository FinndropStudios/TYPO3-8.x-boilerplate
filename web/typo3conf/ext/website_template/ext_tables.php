<?php

/**
 * @var $_EXTKEY string
 */

if(!defined('TYPO3_MODE')) {
	die ('Access denied.');
}

// Default Templates
\TYPO3\CMS\Core\Utility\ExtensionManagementUtility::addStaticFile($_EXTKEY, 'Configuration/TypoScript', 'Website Template');

/**
 * mask_export activate tables here
 */
// \TYPO3\CMS\Core\Utility\ExtensionManagementUtility::allowTableOnStandardPages('tx_websitetemplate_KEY');
