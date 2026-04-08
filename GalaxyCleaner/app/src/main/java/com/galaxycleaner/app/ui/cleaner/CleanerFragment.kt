package com.galaxycleaner.app.ui.cleaner

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import com.galaxycleaner.app.databinding.FragmentCleanerBinding
import com.galaxycleaner.app.service.CleanerForegroundService
import com.galaxycleaner.app.service.CleanerManager
import com.google.android.material.snackbar.Snackbar
import kotlinx.coroutines.launch

class CleanerFragment : Fragment() {

    private var _binding: FragmentCleanerBinding? = null
    private val binding get() = _binding!!
    private lateinit var cleanerManager: CleanerManager

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentCleanerBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        cleanerManager = CleanerManager(requireContext())

        loadStorageInfo()

        binding.btnClean.setOnClickListener {
            startCleaning()
        }
    }

    private fun loadStorageInfo() {
        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val info = cleanerManager.getStorageInfo()
                val usedPercent = ((info.usedBytes.toDouble() / info.totalBytes) * 100).toInt()

                binding.apply {
                    tvUsedStorage.text = cleanerManager.formatBytes(info.usedBytes)
                    tvTotalStorage.text = "/ ${cleanerManager.formatBytes(info.totalBytes)}"
                    progressStorage.setProgressCompat(usedPercent, true)
                    tvCacheSize.text = cleanerManager.formatBytes(info.cacheBytes)
                    tvTempSize.text = cleanerManager.formatBytes(info.tempBytes)
                    tvFreeStorage.text = cleanerManager.formatBytes(info.freeBytes)
                }
            } catch (e: Exception) {
                Snackbar.make(binding.root, "Erro ao carregar informacoes de armazenamento", Snackbar.LENGTH_SHORT).show()
            }
        }
    }

    private fun startCleaning() {
        val clearCache = binding.checkCache.isChecked
        val clearTemp = binding.checkTemp.isChecked
        val clearThumbnails = binding.checkThumbnails.isChecked
        val clearEmptyFolders = binding.checkEmptyFolders.isChecked

        if (!clearCache && !clearTemp && !clearThumbnails && !clearEmptyFolders) {
            Snackbar.make(binding.root, "Selecione ao menos uma opcao de limpeza", Snackbar.LENGTH_SHORT).show()
            return
        }

        binding.btnClean.isEnabled = false
        binding.progressCleaning.visibility = View.VISIBLE
        binding.cardResult.visibility = View.GONE

        viewLifecycleOwner.lifecycleScope.launch {
            try {
                val result = cleanerManager.performClean(
                    clearCache = clearCache,
                    clearTemp = clearTemp,
                    clearThumbnails = clearThumbnails,
                    clearEmptyFolders = clearEmptyFolders
                )

                binding.apply {
                    progressCleaning.visibility = View.GONE
                    cardResult.visibility = View.VISIBLE
                    tvFreedSpace.text = "${cleanerManager.formatBytes(result.freedBytes)} liberados"
                    tvItemsRemoved.text = "${result.itemsRemoved} itens removidos"
                    btnClean.isEnabled = true
                }

                // Also start foreground service for background clean notification
                startCleanerService()
                loadStorageInfo()

            } catch (e: Exception) {
                binding.progressCleaning.visibility = View.GONE
                binding.btnClean.isEnabled = true
                Snackbar.make(binding.root, "Erro durante a limpeza: ${e.message}", Snackbar.LENGTH_LONG).show()
            }
        }
    }

    private fun startCleanerService() {
        val intent = Intent(requireContext(), CleanerForegroundService::class.java).apply {
            action = CleanerForegroundService.ACTION_CLEAN
        }
        try {
            requireContext().startForegroundService(intent)
        } catch (_: Exception) {
            // Service start failed - clean already done in fragment
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
